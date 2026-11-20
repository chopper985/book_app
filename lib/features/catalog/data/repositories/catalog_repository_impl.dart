// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/learner_progress.dart';
import 'package:AppName/features/catalog/domain/entities/quiz_set_summary.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/domain/entities/track_learning.dart';
import 'package:AppName/features/catalog/domain/entities/track_not_found_failure.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:AppName/features/catalog/domain/repositories/saved_tracks_repository.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/entities/quiz_set.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import 'package:AppName/features/practice/domain/repositories/practice_repository.dart';
import 'package:AppName/features/profile/domain/repositories/profile_repository.dart';

@LazySingleton(as: CatalogRepository)
class CatalogRepositoryImpl implements CatalogRepository {
  final ContentRepository _contentRepository;
  final PracticeRepository _practiceRepository;
  final ProfileRepository _profileRepository;
  final SavedTracksRepository _savedTracksRepository;
  final MockDashboardDataSource _dashboardDataSource;
  final AppClock _clock;

  CatalogRepositoryImpl(
    this._contentRepository,
    this._practiceRepository,
    this._profileRepository,
    this._savedTracksRepository,
    this._dashboardDataSource,
    this._clock,
  );

  /// Practice history, profile and saved track changes, merged.
  @override
  Stream<void> get progressChanges {
    final subscriptions = <StreamSubscription<void>>[];
    late final StreamController<void> controller;
    controller = StreamController<void>(
      onListen: () => subscriptions.addAll([
        _practiceRepository.changes.listen(controller.add),
        _profileRepository.changes.listen(controller.add),
        _savedTracksRepository.changes.listen(controller.add),
      ]),
      onCancel: () async {
        await Future.wait(subscriptions.map((s) => s.cancel()));
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<ExploreDashboard> getDashboard() async {
    final catalog = (await _contentRepository.loadCatalog()).value;
    final progress = await _progress();
    final unfinished = await _practiceRepository.getLatestUnfinished();
    final now = _clock.now();

    return ExploreDashboard(
      learner: _learner(progress),
      continueSession: unfinished == null
          ? null
          : ContinueSession(
              sessionId: unfinished.id,
              setId: unfinished.setId,
              trackId: unfinished.trackId,
              minutesAgo: now.difference(unfinished.updatedAt).inMinutes,
              answeredCount: unfinished.answers.length,
              totalQuestions: unfinished.questionIds.length,
            ),
      dailyChallenge: _dashboardDataSource.dailyChallenge,
      trackCompletion: catalog == null
          ? const {}
          : {
              for (final track in catalog.tracks)
                track.id: progress.completion(
                  catalog.questions
                      .where((question) => question.trackId == track.id)
                      .map((question) => question.id),
                ),
            },
    );
  }

  @override
  Future<Result<List<TrackOverview>>> getTracks() async {
    final result = await _contentRepository.loadCatalog();
    final catalog = result.value;
    if (catalog == null) return Result.failure(result.error!);

    // Tracks of the learner's stack first, content order within each group.
    final stack = _profileRepository.profile?.techStack ?? const <String>[];
    int rank(String trackId) => stack.contains(trackId) ? 0 : 1;
    final tracks = [...catalog.tracks]..sort((a, b) {
        final byStack = rank(a.id).compareTo(rank(b.id));
        return byStack != 0 ? byStack : a.order.compareTo(b.order);
      });

    return Result.success([
      for (final track in tracks)
        TrackOverview(
          track: track,
          setCount: catalog.setsOfTrack(track.id).length,
          questionCount: catalog.questions
              .where((question) => question.trackId == track.id)
              .length,
        ),
    ]);
  }

  @override
  Future<Result<TrackDetail>> getTrackDetail(String trackId) async {
    final result = await _contentRepository.loadCatalog();
    final catalog = result.value;
    if (catalog == null) return Result.failure(result.error!);

    final track = catalog.trackById(trackId);
    if (track == null || !track.isAvailable) {
      return Result.failure(TrackNotFoundFailure(trackId));
    }

    final questionIdsByTopic = _questionIdsByTopic(trackId, catalog);
    final progress = await _progress();
    return Result.success(
      TrackDetail(
        track: track,
        sets: [
          for (final set in catalog.setsOfTrack(trackId))
            _summarize(set, catalog),
        ],
        questionIdsByTopic: questionIdsByTopic,
        learning: TrackLearning(
          learner: _learner(progress),
          isSaved: _savedTracksRepository.isSaved(trackId),
          versionLabel: _dashboardDataSource.versionLabel(trackId),
          dailySnippet: _dashboardDataSource.dailySnippet(trackId),
          topicPractice: {
            for (final entry in questionIdsByTopic.entries)
              if (progress.topicPractice(entry.value) case final practice?)
                entry.key: practice,
          },
        ),
      ),
    );
  }

  Future<LearnerProgress> _progress() async => LearnerProgress.fromResults(
        await _practiceRepository.getResults(),
        now: _clock.now(),
      );

  LearnerSummary _learner(LearnerProgress progress) {
    final profile = _profileRepository.profile;
    return LearnerSummary(
      displayName: profile?.displayName ?? '',
      experience: profile?.experience,
      daysToInterview: profile?.daysToInterview(_clock.now()),
      level: progress.level,
      xp: progress.xp,
      streakDays: progress.streakDays,
      practicedCount: progress.practicedCount,
      accuracyPercent: progress.accuracyPercent,
    );
  }

  Map<String, List<String>> _questionIdsByTopic(
    String trackId,
    ContentCatalog catalog,
  ) {
    final result = <String, List<String>>{};
    for (final question in catalog.questions) {
      if (question.trackId != trackId) continue;
      result.putIfAbsent(question.topicId, () => []).add(question.id);
    }
    return result;
  }

  QuizSetSummary _summarize(QuizSet set, ContentCatalog catalog) {
    final questions =
        set.questionIds.map(catalog.questionById).nonNulls.toList();
    return QuizSetSummary(
      set: set,
      topicIds: {for (final question in questions) question.topicId},
      levels: {for (final question in questions) question.level},
    );
  }
}

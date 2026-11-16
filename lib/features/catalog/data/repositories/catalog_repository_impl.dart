// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/quiz_set_summary.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/domain/entities/track_not_found_failure.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/entities/quiz_set.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';

@LazySingleton(as: CatalogRepository)
class CatalogRepositoryImpl implements CatalogRepository {
  final ContentRepository _contentRepository;
  final MockDashboardDataSource _dashboardDataSource;

  CatalogRepositoryImpl(this._contentRepository, this._dashboardDataSource);

  @override
  Future<ExploreDashboard> getDashboard() async => _dashboardDataSource.load();

  @override
  Future<Result<List<TrackOverview>>> getTracks() async {
    final result = await _contentRepository.loadCatalog();
    final catalog = result.value;
    if (catalog == null) return Result.failure(result.error!);

    return Result.success([
      for (final track in [...catalog.tracks]
        ..sort((a, b) => a.order.compareTo(b.order)))
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

    return Result.success(
      TrackDetail(
        track: track,
        sets: [
          for (final set in catalog.setsOfTrack(trackId))
            _summarize(set, catalog),
        ],
        questionIdsByTopic: _questionIdsByTopic(trackId, catalog),
        learning: _dashboardDataSource.loadTrackLearning(trackId),
      ),
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

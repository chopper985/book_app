// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/analytics/app_analytics.dart';
import 'package:AppName/features/catalog/domain/entities/quiz_set_summary.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/domain/usecase/filter_quiz_sets.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/catalog/domain/usecase/get_track_detail.dart';
import 'package:AppName/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:AppName/features/content/domain/entities/content_failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';
import 'package:AppName/features/content/domain/entities/question.dart';

part 'track_detail_state.dart';

@injectable
class TrackDetailCubit extends Cubit<TrackDetailState> {
  final GetTrackDetail _getTrackDetail;
  final ToggleSavedTrack _toggleSavedTrack;
  final FilterQuizSets _filterQuizSets = const FilterQuizSets();
  late final StreamSubscription<void> _progressSubscription;

  final AppAnalytics _analytics;

  TrackDetailCubit(
    this._getTrackDetail,
    this._toggleSavedTrack,
    WatchProgress watchProgress, {
    AppAnalytics analytics = const NoopAppAnalytics(),
  })  : _analytics = analytics,
        super(const TrackDetailLoading()) {
    _progressSubscription = watchProgress().listen((_) => refresh());
  }

  /// Reloads topic progress after practice, keeping the selected filters.
  Future<void> refresh() async {
    final current = state;
    if (current is! TrackDetailLoaded) return;
    final detail = (await _getTrackDetail(
      current.detail.track.id,
      maxLevel: _maxLevel,
    ))
        .value;
    final latest = state;
    if (isClosed || detail == null || latest is! TrackDetailLoaded) return;
    emit(_loaded(detail, topicId: latest.topicId, level: latest.level));
  }

  /// Bookmarks or un-bookmarks the track; the change stream refreshes state.
  Future<void> toggleSaved() async {
    final current = state;
    if (current is TrackDetailLoaded) {
      final trackId = current.detail.track.id;
      await _toggleSavedTrack(trackId);
      _analytics.trackSaved(
        trackId: trackId,
        saved: !current.detail.learning.isSaved,
      );
    }
  }

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    return super.close();
  }

  QuestionLevel? _maxLevel;

  Future<void> load(String trackId, {QuestionLevel? maxLevel}) async {
    _maxLevel = maxLevel;
    emit(const TrackDetailLoading());
    final result = await _getTrackDetail(trackId, maxLevel: maxLevel);
    final detail = result.value;
    if (detail != null) {
      emit(_loaded(detail));
      return;
    }
    final error = result.error;
    emit(
      error is ContentFailure
          ? TrackDetailInvalidContent(error.issues)
          : const TrackDetailNotFound(),
    );
  }

  void selectTopic(String? topicId) {
    final current = state;
    if (current is! TrackDetailLoaded) return;
    emit(_loaded(current.detail, topicId: topicId, level: current.level));
  }

  void selectLevel(QuestionLevel? level) {
    final current = state;
    if (current is! TrackDetailLoaded) return;
    emit(_loaded(current.detail, topicId: current.topicId, level: level));
  }

  TrackDetailLoaded _loaded(
    TrackDetail detail, {
    String? topicId,
    QuestionLevel? level,
  }) {
    return TrackDetailLoaded(
      detail: detail,
      topicId: topicId,
      level: level,
      visibleSets: _filterQuizSets(
        detail.sets,
        topicId: topicId,
        level: level,
      ),
    );
  }
}

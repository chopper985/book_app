// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/usecase/filter_tracks.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:AppName/features/content/domain/entities/content_failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';

part 'roadmaps_state.dart';

/// Roadmaps tab: the full library with search, category filter and saved
/// tracks.
@injectable
class RoadmapsCubit extends Cubit<RoadmapsState> {
  final GetTracks _getTracks;
  final GetExploreDashboard _getDashboard;
  final GetSavedTrackIds _getSavedTrackIds;
  final FilterTracks _filterTracks = const FilterTracks();
  late final StreamSubscription<void> _subscription;

  RoadmapsCubit(
    this._getTracks,
    this._getDashboard,
    this._getSavedTrackIds,
    WatchProgress watchProgress,
  ) : super(const RoadmapsLoading()) {
    _subscription = watchProgress().listen((_) => _reload());
  }

  Future<void> load() async {
    emit(const RoadmapsLoading());
    await _reload();
  }

  void selectCategory(String? category) {
    final current = state;
    if (current is RoadmapsLoaded) {
      emit(_filtered(current, category: category, query: current.query));
    }
  }

  void search(String query) {
    final current = state;
    if (current is RoadmapsLoaded) {
      emit(_filtered(current, category: current.category, query: query));
    }
  }

  /// Keeps the filters while progress, bookmarks or the profile change.
  Future<void> _reload() async {
    final result = await _getTracks();
    final tracks = result.value;
    if (isClosed) return;
    if (tracks == null) {
      final error = result.error;
      emit(
        RoadmapsInvalidContent(
          error is ContentFailure ? error.issues : const [],
        ),
      );
      return;
    }
    final dashboard = await _getDashboard();
    if (isClosed) return;
    final previous = state;
    final byId = {for (final overview in tracks) overview.track.id: overview};
    final base = RoadmapsLoaded(
      tracks: tracks,
      visibleTracks: tracks,
      savedTracks: [
        for (final id in _getSavedTrackIds())
          if (byId[id] case final overview?) overview,
      ],
      dashboard: dashboard,
    );
    emit(
      previous is RoadmapsLoaded
          ? _filtered(base, category: previous.category, query: previous.query)
          : base,
    );
  }

  RoadmapsLoaded _filtered(
    RoadmapsLoaded state, {
    required String? category,
    required String query,
  }) {
    return RoadmapsLoaded(
      tracks: state.tracks,
      visibleTracks: _filterTracks(state.tracks, category, query: query),
      savedTracks: state.savedTracks,
      dashboard: state.dashboard,
      category: category,
      query: query,
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

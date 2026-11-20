// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';

part 'roadmaps_state.dart';

/// Roadmaps tab: the learner's roadmaps (track + level) and the active one.
@injectable
class RoadmapsCubit extends Cubit<RoadmapsState> {
  final GetUserRoadmaps _getUserRoadmaps;
  final SelectUserRoadmap _selectUserRoadmap;
  final RemoveUserRoadmap _removeUserRoadmap;
  final GetTracks _getTracks;
  final GetExploreDashboard _getDashboard;
  final GetPositions _getPositions;
  late final StreamSubscription<void> _subscription;

  RoadmapsCubit(
    this._getUserRoadmaps,
    this._selectUserRoadmap,
    this._removeUserRoadmap,
    this._getTracks,
    this._getDashboard,
    this._getPositions,
    WatchProgress watchProgress,
  ) : super(const RoadmapsLoading()) {
    _subscription = watchProgress().listen((_) => load());
  }

  Future<void> load() async {
    final tracks = (await _getTracks()).value ?? const <TrackOverview>[];
    final dashboard = await _getDashboard();
    final positions = (await _getPositions()).value ?? const <Position>[];
    if (isClosed) return;
    final byId = {for (final overview in tracks) overview.track.id: overview};
    final data = _getUserRoadmaps();
    final positionsById = {for (final p in positions) p.id: p};
    // Roadmaps whose track or position no longer exists are ignored.
    bool exists(UserRoadmap r) =>
        byId.containsKey(r.trackId) &&
        (!r.isPosition ||
            positionsById[r.positionId]?.optionById(r.optionId!) != null);
    final roadmaps = data.roadmaps.where(exists).toList();
    final active = data.active != null && exists(data.active!)
        ? data.active
        : roadmaps.firstOrNull;
    emit(
      RoadmapsLoaded(
        roadmaps: roadmaps,
        active: active,
        tracks: byId,
        positions: positionsById,
        learner: dashboard.learner,
      ),
    );
  }

  /// The change stream reloads the state.
  Future<void> select(String roadmapId) => _selectUserRoadmap(roadmapId);

  Future<void> remove(String roadmapId) => _removeUserRoadmap(roadmapId);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

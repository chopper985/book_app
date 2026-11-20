// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:AppName/features/content/domain/entities/content_failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';

part 'explore_state.dart';

/// Explore tab: the learner's home (greeting, continue, their roadmaps).
@injectable
class ExploreCubit extends Cubit<ExploreState> {
  final GetTracks _getTracks;
  final GetExploreDashboard _getDashboard;
  final GetProfile _getProfile;
  final OpenTrackRoadmap _openTrackRoadmap;
  late final StreamSubscription<void> _progressSubscription;

  ExploreCubit(
    this._getTracks,
    this._getDashboard,
    this._getProfile,
    this._openTrackRoadmap,
    WatchProgress watchProgress,
  ) : super(const ExploreLoading()) {
    _progressSubscription = watchProgress().listen((_) => refresh());
  }

  Future<void> load() async {
    emit(const ExploreLoading());
    await _emitLoaded();
  }

  /// Reloads without showing the loading state again.
  Future<void> refresh() async {
    if (state is ExploreLoaded) await _emitLoaded();
  }

  Future<void> _emitLoaded() async {
    final result = await _getTracks();
    final tracks = result.value;
    if (tracks == null) {
      final error = result.error;
      if (!isClosed) {
        emit(
          ExploreInvalidContent(
            error is ContentFailure ? error.issues : const [],
          ),
        );
      }
      return;
    }
    final dashboard = await _getDashboard();
    if (isClosed) return;
    emit(
      ExploreLoaded(
        tracks: tracks,
        myTracks: _myTracks(tracks),
        dashboard: dashboard,
      ),
    );
  }

  List<TrackOverview> _myTracks(List<TrackOverview> tracks) {
    final byId = {for (final overview in tracks) overview.track.id: overview};
    final mine = [
      for (final id in _getProfile()?.techStack ?? const <String>[])
        if (byId[id] case final overview?) overview,
    ];
    return mine.isNotEmpty
        ? mine
        : tracks.where((overview) => overview.track.isAvailable).toList();
  }

  /// Makes [trackId] the active roadmap (adding it at the suggested level when
  /// the learner has none for it) before switching to the Roadmaps tab.
  Future<void> openTrack(String trackId) => _openTrackRoadmap(trackId);

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    return super.close();
  }
}

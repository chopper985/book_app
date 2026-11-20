part of 'explore_cubit.dart';

sealed class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

final class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

final class ExploreLoaded extends ExploreState {
  final List<TrackOverview> tracks;

  /// Tracks of the learner's tech stack in pick order; the available tracks
  /// when the stack matches none.
  final List<TrackOverview> myTracks;
  final ExploreDashboard dashboard;

  const ExploreLoaded({
    required this.tracks,
    required this.myTracks,
    required this.dashboard,
  });

  TrackOverview? trackById(String id) {
    for (final overview in tracks) {
      if (overview.track.id == id) return overview;
    }
    return null;
  }

  @override
  List<Object?> get props => [tracks, myTracks, dashboard];
}

final class ExploreInvalidContent extends ExploreState {
  final List<ContentIssue> issues;

  const ExploreInvalidContent(this.issues);

  @override
  List<Object?> get props => [issues];
}

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
  final List<TrackOverview> visibleTracks;
  final ExploreDashboard dashboard;
  final String? category;

  const ExploreLoaded({
    required this.tracks,
    required this.visibleTracks,
    required this.dashboard,
    this.category,
  });

  TrackOverview? trackById(String id) {
    for (final overview in tracks) {
      if (overview.track.id == id) return overview;
    }
    return null;
  }

  @override
  List<Object?> get props => [tracks, visibleTracks, dashboard, category];
}

final class ExploreInvalidContent extends ExploreState {
  final List<ContentIssue> issues;

  const ExploreInvalidContent(this.issues);

  @override
  List<Object?> get props => [issues];
}

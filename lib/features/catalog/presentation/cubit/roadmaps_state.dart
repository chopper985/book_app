part of 'roadmaps_cubit.dart';

sealed class RoadmapsState extends Equatable {
  const RoadmapsState();

  @override
  List<Object?> get props => [];
}

final class RoadmapsLoading extends RoadmapsState {
  const RoadmapsLoading();
}

final class RoadmapsInvalidContent extends RoadmapsState {
  final List<ContentIssue> issues;

  const RoadmapsInvalidContent(this.issues);

  @override
  List<Object?> get props => [issues];
}

final class RoadmapsLoaded extends RoadmapsState {
  final List<TrackOverview> tracks;

  /// [tracks] after the category and search filters.
  final List<TrackOverview> visibleTracks;

  /// Bookmarked tracks, most recently saved first. Hidden while searching.
  final List<TrackOverview> savedTracks;
  final ExploreDashboard dashboard;
  final String? category;
  final String query;

  const RoadmapsLoaded({
    required this.tracks,
    required this.visibleTracks,
    required this.savedTracks,
    required this.dashboard,
    this.category,
    this.query = '',
  });

  bool get isFiltering => category != null || query.trim().isNotEmpty;

  @override
  List<Object?> get props =>
      [tracks, visibleTracks, savedTracks, dashboard, category, query];
}

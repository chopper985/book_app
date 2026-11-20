part of 'roadmaps_cubit.dart';

sealed class RoadmapsState extends Equatable {
  const RoadmapsState();

  @override
  List<Object?> get props => [];
}

final class RoadmapsLoading extends RoadmapsState {
  const RoadmapsLoading();
}

final class RoadmapsLoaded extends RoadmapsState {
  /// Most recently selected first.
  final List<UserRoadmap> roadmaps;

  /// `null` until the learner picks a language and a level.
  final UserRoadmap? active;

  /// Track per id, for names and icons in the switcher.
  final Map<String, TrackOverview> tracks;

  /// Position per id, for position roadmap names.
  final Map<String, Position> positions;

  /// Header data (role label, streak).
  final LearnerSummary learner;

  const RoadmapsLoaded({
    required this.roadmaps,
    required this.active,
    required this.tracks,
    required this.learner,
    this.positions = const {},
  });

  @override
  List<Object?> get props => [roadmaps, active, tracks, positions, learner];
}

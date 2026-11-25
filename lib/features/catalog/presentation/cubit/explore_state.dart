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

  /// Tracks of the learner's roadmaps (most recent first); the tech stack
  /// before any roadmap exists, the available tracks when both are empty.
  final List<TrackOverview> myTracks;
  final ExploreDashboard dashboard;

  /// Technologies per position (Mobile, Front-end, Back-end, Tester).
  final List<RoleTechnologies> roles;

  /// Position shown in the "by role" section.
  final String? selectedRoleId;

  /// Tracks covered by the learner's roadmaps (language or position).
  final Set<String> roadmapTrackIds;

  const ExploreLoaded({
    required this.tracks,
    required this.myTracks,
    required this.dashboard,
    this.roles = const [],
    this.selectedRoleId,
    this.roadmapTrackIds = const {},
  });

  RoleTechnologies? get selectedRole {
    for (final role in roles) {
      if (role.position.id == selectedRoleId) return role;
    }
    return roles.isEmpty ? null : roles.first;
  }

  ExploreLoaded copyWith({String? selectedRoleId}) => ExploreLoaded(
        tracks: tracks,
        myTracks: myTracks,
        dashboard: dashboard,
        roles: roles,
        selectedRoleId: selectedRoleId ?? this.selectedRoleId,
        roadmapTrackIds: roadmapTrackIds,
      );

  TrackOverview? trackById(String id) {
    for (final overview in tracks) {
      if (overview.track.id == id) return overview;
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [tracks, myTracks, dashboard, roles, selectedRoleId, roadmapTrackIds];
}

final class ExploreInvalidContent extends ExploreState {
  final List<ContentIssue> issues;

  const ExploreInvalidContent(this.issues);

  @override
  List<Object?> get props => [issues];
}

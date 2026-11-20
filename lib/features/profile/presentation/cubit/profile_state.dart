part of 'profile_cubit.dart';

/// A track with the learner's completion (0..1).
class TrackCompletion extends Equatable {
  final TrackOverview overview;
  final double completion;

  const TrackCompletion(this.overview, this.completion);

  @override
  List<Object?> get props => [overview, completion];
}

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final LearnerProfile? profile;

  /// Absolute path of the avatar image, `null` when none.
  final String? avatarPath;
  final LearnerSummary learner;

  /// Tracks of the profile's tech stack, in pick order.
  final List<TrackOverview> stack;

  /// Available tracks, the learner's stack first.
  final List<TrackCompletion> tracks;

  /// Saved tracks, most recently saved first.
  final List<TrackOverview> savedTracks;

  const ProfileLoaded({
    required this.profile,
    required this.learner,
    this.avatarPath,
    required this.stack,
    required this.tracks,
    required this.savedTracks,
  });

  @override
  List<Object?> get props =>
      [profile, avatarPath, learner, stack, tracks, savedTracks];
}

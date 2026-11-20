part of 'profile_cubit.dart';

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

  const ProfileLoaded({
    required this.profile,
    required this.learner,
    this.avatarPath,
    required this.stack,
  });

  @override
  List<Object?> get props =>
      [profile, avatarPath, learner, stack];
}

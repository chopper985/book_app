part of 'practice_hub_cubit.dart';

sealed class PracticeHubState extends Equatable {
  const PracticeHubState();

  @override
  List<Object?> get props => [];
}

final class PracticeHubLoading extends PracticeHubState {
  const PracticeHubLoading();
}

final class PracticeHubInvalidContent extends PracticeHubState {
  final List<ContentIssue> issues;

  const PracticeHubInvalidContent(this.issues);

  @override
  List<Object?> get props => [issues];
}

final class PracticeHubLoaded extends PracticeHubState {
  final PracticeHub hub;

  /// Header data (role label, streak).
  final LearnerSummary learner;

  const PracticeHubLoaded({required this.hub, required this.learner});

  @override
  List<Object?> get props => [hub, learner];
}

part of 'practice_cubit.dart';

sealed class PracticeState extends Equatable {
  const PracticeState();

  @override
  List<Object?> get props => [];
}

final class PracticeLoading extends PracticeState {
  const PracticeLoading();
}

final class PracticeNotFound extends PracticeState {
  const PracticeNotFound();
}

/// The plan does not allow a new session (Premium set or no sessions left).
final class PracticeLocked extends PracticeState {
  final PracticeDenial reason;

  const PracticeLocked(this.reason);

  @override
  List<Object?> get props => [reason];
}

final class PracticeInProgress extends PracticeState {
  final PracticeBundle bundle;

  const PracticeInProgress(this.bundle);

  @override
  List<Object?> get props => [bundle];
}

final class PracticeSubmitted extends PracticeState {
  final String sessionId;

  const PracticeSubmitted(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

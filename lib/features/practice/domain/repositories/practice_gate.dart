// Project imports:
import 'package:interview_practice/core/error/failure.dart';

/// Why a new practice session cannot start.
enum PracticeDenial {
  /// Middle/Senior set without Premium (extra sessions do not unlock it).
  premiumLevel,

  /// No sessions left today and no extra sessions.
  quotaExhausted,
}

class PracticeLockedFailure extends Failure {
  final PracticeDenial reason;

  PracticeLockedFailure(this.reason);

  @override
  List<Object> get props => [reason];
}

/// Decides whether a new session may start and counts it (implemented by
/// the premium feature). Resuming a session never goes through the gate.
abstract class PracticeGate {
  Future<PracticeDenial?> check(String setId);

  /// Counts one session: today's allowance first, then an extra session.
  Future<void> consume();
}

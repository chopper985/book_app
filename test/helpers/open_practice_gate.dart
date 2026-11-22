// Project imports:
import 'package:interview_practice/features/practice/domain/repositories/practice_gate.dart';

/// Lets every session start (tests that are not about plans and quotas).
class OpenPracticeGate implements PracticeGate {
  const OpenPracticeGate();

  @override
  Future<PracticeDenial?> check(String setId) async => null;

  @override
  Future<void> consume() async {}
}

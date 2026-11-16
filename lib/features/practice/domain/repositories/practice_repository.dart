// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/practice/domain/entities/practice_bundle.dart';
import 'package:AppName/features/practice/domain/entities/practice_session.dart';

abstract class PracticeRepository {
  /// Starts a session for [setId]. [onlyQuestionIds] limits it to a subset,
  /// e.g. the mistakes of a previous session.
  Future<Result<PracticeBundle>> startSession(
    String setId, {
    List<String>? onlyQuestionIds,
  });

  Future<void> saveSession(PracticeSession session);

  /// Grades the session. Idempotent: a session has exactly one result, so a
  /// second call (manual submit racing the timer) returns the first result.
  Future<Result<ResultBundle>> submit(String sessionId, {bool timedOut});

  Future<Result<ResultBundle>> getResult(String sessionId);
}

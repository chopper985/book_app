// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_session.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';

abstract class PracticeRepository {
  /// Starts a session for [setId]. [onlyQuestionIds] limits it to a subset,
  /// e.g. the mistakes of a previous session.
  Future<Result<PracticeBundle>> startSession(
    String setId, {
    List<String>? onlyQuestionIds,
  });

  /// Reopens an unfinished session. Fails when it was already submitted,
  /// expired or its content no longer exists.
  Future<Result<PracticeBundle>> resumeSession(String sessionId);

  Future<void> saveSession(PracticeSession session);

  /// Grades the session. Idempotent: a session has exactly one result, so a
  /// second call (manual submit racing the timer) returns the first result.
  Future<Result<ResultBundle>> submit(String sessionId, {bool timedOut});

  Future<Result<ResultBundle>> getResult(String sessionId);

  /// Every graded session, oldest first.
  Future<List<SessionResult>> getResults();

  /// The most recently touched session that is not submitted nor expired.
  Future<PracticeSession?> getLatestUnfinished();

  /// Stores results from another device (cloud sync); existing ids are kept.
  Future<void> importResults(List<SessionResult> results);

  /// Deletes every session and result on the device.
  Future<void> clearHistory();

  /// Fires after a session is started, saved or submitted so screens showing
  /// progress can refresh.
  Stream<void> get changes;
}

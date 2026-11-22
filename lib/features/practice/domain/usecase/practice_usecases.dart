// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_session.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_gate.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_repository.dart';

@injectable
class StartPractice {
  final PracticeRepository _repository;
  final PracticeGate _gate;

  StartPractice(this._repository, this._gate);

  /// Fails with [PracticeLockedFailure] when the plan does not allow it;
  /// a started session uses one of the learner's sessions.
  Future<Result<PracticeBundle>> call(
    String setId, {
    List<String>? onlyQuestionIds,
  }) async {
    final denial = await _gate.check(setId);
    if (denial != null) return Result.failure(PracticeLockedFailure(denial));
    final result = await _repository.startSession(
      setId,
      onlyQuestionIds: onlyQuestionIds,
    );
    if (result.isSuccess) await _gate.consume();
    return result;
  }
}

@injectable
class ResumePractice {
  final PracticeRepository _repository;

  ResumePractice(this._repository);

  Future<Result<PracticeBundle>> call(String sessionId) =>
      _repository.resumeSession(sessionId);
}

@injectable
class ClearPracticeHistory {
  final PracticeRepository _repository;

  ClearPracticeHistory(this._repository);

  Future<void> call() => _repository.clearHistory();
}

@injectable
class SavePractice {
  final PracticeRepository _repository;

  SavePractice(this._repository);

  Future<void> call(PracticeSession session) =>
      _repository.saveSession(session);
}

@injectable
class SubmitPractice {
  final PracticeRepository _repository;

  SubmitPractice(this._repository);

  Future<Result<ResultBundle>> call(
    String sessionId, {
    bool timedOut = false,
  }) =>
      _repository.submit(sessionId, timedOut: timedOut);
}

@injectable
class GetPracticeResult {
  final PracticeRepository _repository;

  GetPracticeResult(this._repository);

  Future<Result<ResultBundle>> call(String sessionId) =>
      _repository.getResult(sessionId);
}

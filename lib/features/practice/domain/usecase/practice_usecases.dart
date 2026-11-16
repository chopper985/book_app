// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/practice/domain/entities/practice_bundle.dart';
import 'package:AppName/features/practice/domain/entities/practice_session.dart';
import 'package:AppName/features/practice/domain/repositories/practice_repository.dart';

@injectable
class StartPractice {
  final PracticeRepository _repository;

  StartPractice(this._repository);

  Future<Result<PracticeBundle>> call(
    String setId, {
    List<String>? onlyQuestionIds,
  }) =>
      _repository.startSession(setId, onlyQuestionIds: onlyQuestionIds);
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

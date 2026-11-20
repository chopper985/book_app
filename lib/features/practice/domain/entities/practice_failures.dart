// Project imports:
import 'package:interview_practice/core/error/failure.dart';

class QuizSetNotFoundFailure extends Failure {
  final String setId;

  QuizSetNotFoundFailure(this.setId);

  @override
  List<Object> get props => [setId];
}

class SessionNotFoundFailure extends Failure {
  final String sessionId;

  SessionNotFoundFailure(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

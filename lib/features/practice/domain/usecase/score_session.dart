// Project imports:
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/practice/domain/entities/practice_session.dart';
import 'package:AppName/features/practice/domain/entities/session_result.dart';

/// Grades a session.
///
/// - Auto-graded questions compare the selected option id with the answer.
/// - Unanswered auto-graded questions are skipped: they count as wrong in the
///   score (they stay in the denominator) and are reported separately.
/// - Self-explain questions are not scored.
class ScoreSession {
  const ScoreSession();

  SessionResult call(
    PracticeSession session,
    Map<String, Question> questions, {
    required DateTime submittedAt,
    bool timedOut = false,
  }) {
    return SessionResult(
      sessionId: session.id,
      setId: session.setId,
      trackId: session.trackId,
      startedAt: session.startedAt,
      submittedAt: submittedAt,
      timedOut: timedOut,
      items: [
        for (final id in session.questionIds)
          _grade(questions[id]!, session.answers[id]),
      ],
    );
  }

  QuestionResult _grade(Question question, String? selected) {
    final AnswerStatus status;
    if (!question.type.isAutoGraded) {
      status = AnswerStatus.selfCheck;
    } else if (selected == null) {
      status = AnswerStatus.skipped;
    } else if (selected == question.answerId) {
      status = AnswerStatus.correct;
    } else {
      status = AnswerStatus.incorrect;
    }
    return QuestionResult(
      questionId: question.id,
      contentVersion: question.contentVersion,
      status: status,
      selectedOptionId: selected,
      correctOptionId: question.answerId,
    );
  }
}

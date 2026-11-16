// Package imports:
import 'package:equatable/equatable.dart';

enum AnswerStatus {
  correct,
  incorrect,
  skipped,

  /// Self-explain question: not scored, the user compares with key points.
  selfCheck;

  bool get isGraded => this != AnswerStatus.selfCheck;
}

class QuestionResult extends Equatable {
  final String questionId;

  /// Content version that was graded, so history keeps the original score
  /// after the content is updated.
  final int contentVersion;
  final AnswerStatus status;
  final String? selectedOptionId;
  final String? correctOptionId;

  const QuestionResult({
    required this.questionId,
    required this.contentVersion,
    required this.status,
    this.selectedOptionId,
    this.correctOptionId,
  });

  @override
  List<Object?> get props => [
        questionId,
        contentVersion,
        status,
        selectedOptionId,
        correctOptionId,
      ];
}

class SessionResult extends Equatable {
  final String sessionId;
  final String setId;
  final String trackId;
  final List<QuestionResult> items;
  final DateTime startedAt;
  final DateTime submittedAt;
  final bool timedOut;

  const SessionResult({
    required this.sessionId,
    required this.setId,
    required this.trackId,
    required this.items,
    required this.startedAt,
    required this.submittedAt,
    this.timedOut = false,
  });

  int _count(AnswerStatus status) =>
      items.where((item) => item.status == status).length;

  /// Denominator: only auto-graded questions.
  int get gradedCount => items.where((item) => item.status.isGraded).length;

  int get correctCount => _count(AnswerStatus.correct);

  /// Answered but wrong. Skipped questions are counted separately.
  int get incorrectCount => _count(AnswerStatus.incorrect);

  int get skippedCount => _count(AnswerStatus.skipped);

  int get selfCheckCount => _count(AnswerStatus.selfCheck);

  /// Correct / graded, 0 when nothing is graded.
  double get scoreRatio => gradedCount == 0 ? 0 : correctCount / gradedCount;

  int get scorePercent => (scoreRatio * 100).round();

  Duration get duration => submittedAt.difference(startedAt);

  /// Wrong and skipped questions, used by "review mistakes".
  List<QuestionResult> get mistakes => items
      .where(
        (item) =>
            item.status == AnswerStatus.incorrect ||
            item.status == AnswerStatus.skipped,
      )
      .toList();

  @override
  List<Object?> get props => [
        sessionId,
        setId,
        trackId,
        items,
        startedAt,
        submittedAt,
        timedOut,
      ];
}

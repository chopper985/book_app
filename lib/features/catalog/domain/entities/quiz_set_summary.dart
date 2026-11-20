// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';

class QuizSetSummary extends Equatable {
  final QuizSet set;
  final Set<String> topicIds;
  final Set<QuestionLevel> levels;

  const QuizSetSummary({
    required this.set,
    required this.topicIds,
    required this.levels,
  });

  int get questionCount => set.questionIds.length;

  @override
  List<Object?> get props => [set, topicIds, levels];
}

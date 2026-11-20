// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';

/// Ordered from easiest to hardest.
enum QuestionLevel {
  fresher,
  junior,
  middle,
  senior;

  /// Middle and above need a paid plan, so they only live in sets with an
  /// `accessPlanId`.
  bool get isPremium => index >= QuestionLevel.middle.index;
}

enum QuestionType {
  multipleChoice,
  outputPrediction,
  findBug,
  selfExplain;

  /// Auto-graded questions are scored by comparing option ids.
  bool get isAutoGraded => this != QuestionType.selfExplain;
}

class CodeSnippet extends Equatable {
  final String language;
  final String source;

  const CodeSnippet({required this.language, required this.source});

  @override
  List<Object?> get props => [language, source];
}

class QuestionOption extends Equatable {
  final String id;
  final LocalizedText text;

  const QuestionOption({required this.id, required this.text});

  @override
  List<Object?> get props => [id, text];
}

class Question extends Equatable {
  /// Stable id shared by every language and content version.
  final String id;
  final int contentVersion;
  final String trackId;
  final String topicId;
  final QuestionLevel level;
  final QuestionType type;
  final LocalizedText prompt;
  final CodeSnippet? code;
  final List<QuestionOption> options;

  /// Correct option id for auto-graded questions.
  final String? answerId;

  /// Points to self-check for [QuestionType.selfExplain].
  final List<LocalizedText> keyPoints;
  final LocalizedText explanation;

  const Question({
    required this.id,
    required this.contentVersion,
    required this.trackId,
    required this.topicId,
    required this.level,
    required this.type,
    required this.prompt,
    required this.options,
    required this.explanation,
    this.code,
    this.answerId,
    this.keyPoints = const [],
  });

  @override
  List<Object?> get props => [
        id,
        contentVersion,
        trackId,
        topicId,
        level,
        type,
        prompt,
        code,
        options,
        answerId,
        keyPoints,
        explanation,
      ];
}

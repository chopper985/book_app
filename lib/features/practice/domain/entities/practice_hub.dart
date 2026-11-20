// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';
import 'package:interview_practice/features/content/domain/entities/track.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';

/// Questions of one set whose latest attempt was wrong or skipped.
class MistakeGroup extends Equatable {
  final QuizSet set;
  final Track track;

  /// In set order.
  final List<String> questionIds;

  const MistakeGroup({
    required this.set,
    required this.track,
    required this.questionIds,
  });

  @override
  List<Object?> get props => [set, track, questionIds];
}

/// A short random practice from one set of a track.
class QuickPractice extends Equatable {
  static const int maxQuestions = 5;

  final Track track;
  final QuizSet set;

  const QuickPractice({required this.track, required this.set});

  int get questionCount => math.min(maxQuestions, set.questionIds.length);

  /// Random question ids, `null` when the whole set is small enough.
  List<String>? pickQuestions([math.Random? random]) {
    final ids = set.questionIds;
    if (ids.length <= maxQuestions) return null;
    return ([...ids]..shuffle(random)).take(maxQuestions).toList();
  }

  @override
  List<Object?> get props => [track, set];
}

/// A graded session with the content needed to list it.
class HistoryEntry extends Equatable {
  final SessionResult result;
  final QuizSet set;
  final Track track;

  const HistoryEntry({
    required this.result,
    required this.set,
    required this.track,
  });

  @override
  List<Object?> get props => [result, set, track];
}

class PracticeHub extends Equatable {
  static const int historyLimit = 20;

  final List<MistakeGroup> mistakes;
  final List<QuickPractice> quickPractices;

  /// Newest first, at most [historyLimit].
  final List<HistoryEntry> history;
  final int sessionCount;

  /// Mean score of the sessions that have graded questions.
  final int averageScorePercent;

  const PracticeHub({
    this.mistakes = const [],
    this.quickPractices = const [],
    this.history = const [],
    this.sessionCount = 0,
    this.averageScorePercent = 0,
  });

  int get mistakeCount =>
      mistakes.fold(0, (sum, group) => sum + group.questionIds.length);

  @override
  List<Object?> get props =>
      [mistakes, quickPractices, history, sessionCount, averageScorePercent];
}

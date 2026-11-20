// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/track_learning.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';

/// Learner statistics derived from the graded sessions on the device.
class LearnerProgress extends Equatable {
  static const int xpPerCorrect = 10;
  static const int xpPerSelfCheck = 5;
  static const int xpPerLevel = 500;

  /// Latest outcome per question id. A later attempt replaces an earlier one,
  /// so fixing a mistake moves the question from wrong to correct.
  final Map<String, AnswerStatus> latestStatus;
  final int xp;
  final int streakDays;

  /// Answered questions over all sessions (skipped ones excluded).
  final int practicedCount;

  /// Correct / graded over all sessions.
  final int accuracyPercent;

  const LearnerProgress({
    this.latestStatus = const {},
    this.xp = 0,
    this.streakDays = 0,
    this.practicedCount = 0,
    this.accuracyPercent = 0,
  });

  static const LearnerProgress empty = LearnerProgress();

  /// [results] in any order; [now] decides whether the streak is still alive.
  factory LearnerProgress.fromResults(
    List<SessionResult> results, {
    required DateTime now,
  }) {
    if (results.isEmpty) return empty;
    final sorted = [...results]
      ..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));

    final latest = <String, AnswerStatus>{};
    var correct = 0;
    var graded = 0;
    var practiced = 0;
    var xp = 0;
    for (final result in sorted) {
      for (final item in result.items) {
        latest[item.questionId] = item.status;
        switch (item.status) {
          case AnswerStatus.correct:
            correct++;
            graded++;
            practiced++;
            xp += xpPerCorrect;
          case AnswerStatus.incorrect:
            graded++;
            practiced++;
          case AnswerStatus.skipped:
            graded++;
          case AnswerStatus.selfCheck:
            practiced++;
            xp += xpPerSelfCheck;
        }
      }
    }

    return LearnerProgress(
      latestStatus: latest,
      xp: xp,
      streakDays: _streak(sorted.map((r) => r.submittedAt), now),
      practicedCount: practiced,
      accuracyPercent: graded == 0 ? 0 : (correct * 100 / graded).round(),
    );
  }

  /// 1-based level from [xp].
  int get level => xp ~/ xpPerLevel + 1;

  /// Share of [questionIds] answered at least once (0..1).
  double completion(Iterable<String> questionIds) {
    var total = 0;
    var done = 0;
    for (final id in questionIds) {
      total++;
      final status = latestStatus[id];
      if (status != null && status != AnswerStatus.skipped) done++;
    }
    return total == 0 ? 0 : done / total;
  }

  /// Correct and wrong shares of [questionIds] by their latest outcome. A
  /// reviewed self-explain question counts as correct; a skip counts as wrong.
  TopicPractice? topicPractice(List<String> questionIds) {
    if (questionIds.isEmpty) return null;
    var correct = 0;
    var wrong = 0;
    for (final id in questionIds) {
      switch (latestStatus[id]) {
        case AnswerStatus.correct || AnswerStatus.selfCheck:
          correct++;
        case AnswerStatus.incorrect || AnswerStatus.skipped:
          wrong++;
        case null:
          break;
      }
    }
    if (correct + wrong == 0) return null;
    return TopicPractice(
      correctRatio: correct / questionIds.length,
      wrongRatio: wrong / questionIds.length,
    );
  }

  /// Consecutive days with a submitted session, ending today or yesterday.
  static int _streak(Iterable<DateTime> submittedAt, DateTime now) {
    final days = {for (final date in submittedAt) _day(date)};
    var day = _day(now);
    if (!days.contains(day)) {
      day = _previousDay(day);
      if (!days.contains(day)) return 0;
    }
    var streak = 0;
    while (days.contains(day)) {
      streak++;
      day = _previousDay(day);
    }
    return streak;
  }

  static DateTime _day(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Calendar arithmetic, safe across daylight saving changes.
  static DateTime _previousDay(DateTime day) =>
      DateTime(day.year, day.month, day.day - 1);

  @override
  List<Object?> get props =>
      [latestStatus, xp, streakDays, practicedCount, accuracyPercent];
}

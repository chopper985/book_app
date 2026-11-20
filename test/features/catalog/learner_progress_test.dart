// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/learner_progress.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';

SessionResult result(
  DateTime submittedAt,
  Map<String, AnswerStatus> statuses,
) =>
    SessionResult(
      sessionId: 's-${submittedAt.toIso8601String()}',
      setId: 'dart.set1',
      trackId: 'dart',
      startedAt: submittedAt.subtract(const Duration(minutes: 5)),
      submittedAt: submittedAt,
      items: [
        for (final entry in statuses.entries)
          QuestionResult(
            questionId: entry.key,
            contentVersion: 1,
            status: entry.value,
          ),
      ],
    );

void main() {
  final now = DateTime(2026, 11, 20, 21);

  test('no history is empty progress', () {
    final progress = LearnerProgress.fromResults(const [], now: now);
    expect(progress, LearnerProgress.empty);
    expect(progress.level, 1);
    expect(progress.completion(['q1']), 0);
    expect(progress.topicPractice(['q1']), isNull);
  });

  test('counts xp, practiced and accuracy over all sessions', () {
    final progress = LearnerProgress.fromResults(
      [
        result(DateTime(2026, 11, 20, 9), {
          'q1': AnswerStatus.correct,
          'q2': AnswerStatus.incorrect,
          'q3': AnswerStatus.skipped,
          'q4': AnswerStatus.selfCheck,
        }),
      ],
      now: now,
    );
    // 1 correct (10) + 1 self-check (5).
    expect(progress.xp, 15);
    // Skipped is not practiced.
    expect(progress.practicedCount, 3);
    // 1 correct of 3 graded (skip counts as graded).
    expect(progress.accuracyPercent, 33);
  });

  test('a later attempt replaces the outcome of a question', () {
    final progress = LearnerProgress.fromResults(
      [
        // Given out of order on purpose.
        result(DateTime(2026, 11, 20, 10), {'q1': AnswerStatus.correct}),
        result(DateTime(2026, 11, 19, 10), {
          'q1': AnswerStatus.incorrect,
          'q2': AnswerStatus.skipped,
        }),
      ],
      now: now,
    );
    expect(progress.latestStatus, {
      'q1': AnswerStatus.correct,
      'q2': AnswerStatus.skipped,
    });
    expect(progress.completion(['q1', 'q2', 'q3', 'q4']), 0.25);
    final topic = progress.topicPractice(['q1', 'q2', 'q3', 'q4'])!;
    expect(topic.correctRatio, 0.25);
    expect(topic.wrongRatio, 0.25);
  });

  group('streak', () {
    int streakOf(List<DateTime> days) => LearnerProgress.fromResults(
          [for (final day in days) result(day, {'q1': AnswerStatus.correct})],
          now: now,
        ).streakDays;

    test('counts consecutive days ending today', () {
      expect(
        streakOf([
          DateTime(2026, 11, 18, 23),
          DateTime(2026, 11, 19, 8),
          DateTime(2026, 11, 20, 7),
          DateTime(2026, 11, 20, 8),
        ]),
        3,
      );
    });

    test('is still alive when the last session was yesterday', () {
      expect(streakOf([DateTime(2026, 11, 19, 8)]), 1);
    });

    test('breaks after a missed day', () {
      expect(streakOf([DateTime(2026, 11, 18, 8)]), 0);
      expect(
        streakOf([DateTime(2026, 11, 17, 8), DateTime(2026, 11, 20, 8)]),
        1,
      );
    });

    test('works across a month boundary', () {
      final progress = LearnerProgress.fromResults(
        [
          result(DateTime(2026, 11, 30, 8), {'q1': AnswerStatus.correct}),
          result(DateTime(2026, 12, 1, 8), {'q1': AnswerStatus.correct}),
        ],
        now: DateTime(2026, 12, 1, 20),
      );
      expect(progress.streakDays, 2);
    });
  });

  test('levels up every 500 xp', () {
    expect(const LearnerProgress(xp: 499).level, 1);
    expect(const LearnerProgress(xp: 500).level, 2);
  });
}

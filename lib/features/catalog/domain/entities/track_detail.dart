// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/quiz_set_summary.dart';
import 'package:AppName/features/catalog/domain/entities/track_learning.dart';
import 'package:AppName/features/catalog/domain/entities/track_progress.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/content/domain/entities/track.dart';

/// A set to start, optionally limited to some of its questions.
class PracticeTarget extends Equatable {
  final String setId;
  final List<String>? onlyQuestionIds;

  const PracticeTarget({required this.setId, this.onlyQuestionIds});

  @override
  List<Object?> get props => [setId, onlyQuestionIds];
}

class TrackDetail extends Equatable {
  final Track track;
  final List<QuizSetSummary> sets;

  /// Question ids of the track grouped by topic id.
  final Map<String, List<String>> questionIdsByTopic;
  final TrackLearning learning;

  /// Hardest level included; `null` shows every level.
  final QuestionLevel? maxLevel;

  /// Generated set with every question of a topic in range, per topic id.
  final Map<String, String> topicSetIds;

  const TrackDetail({
    required this.track,
    required this.sets,
    this.questionIdsByTopic = const {},
    this.learning = TrackLearning.empty,
    this.maxLevel,
    this.topicSetIds = const {},
  });

  int get questionCount =>
      questionIdsByTopic.values.fold(0, (sum, ids) => sum + ids.length);

  /// Topics with questions in range only.
  TrackProgress get progress => TrackProgress([
        for (final topic in track.topics)
          if (questionIdsByTopic[topic.id]?.isNotEmpty ?? false)
            TopicProgress.from(
            topic,
            questionIdsByTopic[topic.id]?.length ?? 0,
            learning.topicPractice[topic.id],
          ),
      ]);

  QuizSetSummary? get firstFreeSet {
    for (final summary in sets) {
      if (summary.set.isFree) return summary;
    }
    return null;
  }

  QuizSetSummary? get firstTimedSet {
    for (final summary in sets) {
      if (summary.set.isTimed) return summary;
    }
    return null;
  }

  /// Up to [maxQuestions] random questions of the first free set.
  PracticeTarget? quickPractice({int maxQuestions = 5, math.Random? random}) {
    final summary = firstFreeSet;
    if (summary == null) return null;
    final ids = summary.set.questionIds;
    if (ids.length <= maxQuestions) {
      return PracticeTarget(setId: summary.set.id);
    }
    return PracticeTarget(
      setId: summary.set.id,
      onlyQuestionIds: ([...ids]..shuffle(random)).take(maxQuestions).toList(),
    );
  }

  /// Every question of [topicId] in range: its generated topic set, else the
  /// first set containing the topic limited to that topic's questions.
  PracticeTarget? topicPractice(String topicId) {
    if (topicSetIds[topicId] case final setId?) {
      return PracticeTarget(setId: setId);
    }
    final topicIds = (questionIdsByTopic[topicId] ?? const []).toSet();
    for (final summary in sets) {
      if (!summary.topicIds.contains(topicId)) continue;
      final only = summary.set.questionIds.where(topicIds.contains).toList();
      return PracticeTarget(
        setId: summary.set.id,
        onlyQuestionIds: only.isEmpty ? null : only,
      );
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [track, sets, questionIdsByTopic, learning, maxLevel, topicSetIds];
}

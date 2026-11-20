// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/content/domain/entities/localized_text.dart';

/// How much of a topic the learner has practiced, as ratios of the topic's
/// questions so it stays consistent with the real question count.
class TopicPractice extends Equatable {
  final double correctRatio;
  final double wrongRatio;

  /// Estimated minutes to finish the topic, `null` when not estimated.
  final int? estimatedMinutes;

  const TopicPractice({
    required this.correctRatio,
    required this.wrongRatio,
    this.estimatedMinutes,
  });

  @override
  List<Object?> get props => [correctRatio, wrongRatio, estimatedMinutes];
}

/// Short code puzzle teased at the bottom of a track.
class DailySnippet extends Equatable {
  final String code;
  final LocalizedText question;
  final int rewardXp;

  const DailySnippet({
    required this.code,
    required this.question,
    required this.rewardXp,
  });

  @override
  List<Object?> get props => [code, question, rewardXp];
}

/// Learner data of one track.
class TrackLearning extends Equatable {
  final LearnerSummary? learner;
  final bool isSaved;

  /// Technology version label such as "Dart 3.x".
  final String? versionLabel;

  /// Practice per topic id.
  final Map<String, TopicPractice> topicPractice;
  final DailySnippet? dailySnippet;

  const TrackLearning({
    this.learner,
    this.isSaved = false,
    this.versionLabel,
    this.topicPractice = const {},
    this.dailySnippet,
  });

  static const TrackLearning empty = TrackLearning();

  @override
  List<Object?> get props =>
      [learner, isSaved, versionLabel, topicPractice, dailySnippet];
}

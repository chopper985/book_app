// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/track_learning.dart';
import 'package:AppName/features/content/domain/entities/track.dart';

enum TopicStatus { almostDone, learning, needsReview, lowPractice }

class TopicProgress extends Equatable {
  /// Answered at least this share of the topic: almost done.
  static const double almostDoneRatio = 0.75;

  /// Answered less than this share of the topic: barely practiced.
  static const double lowPracticeRatio = 0.35;

  /// Wrong answers above this share of the answered ones: needs review.
  static const double highErrorRatio = 0.3;

  final Topic topic;
  final int total;
  final int correct;
  final int wrong;
  final int? estimatedMinutes;

  const TopicProgress({
    required this.topic,
    required this.total,
    required this.correct,
    required this.wrong,
    this.estimatedMinutes,
  });

  factory TopicProgress.from(Topic topic, int total, TopicPractice? practice) {
    final correct =
        ((practice?.correctRatio ?? 0) * total).round().clamp(0, total);
    final wrong =
        ((practice?.wrongRatio ?? 0) * total).round().clamp(0, total - correct);
    return TopicProgress(
      topic: topic,
      total: total,
      correct: correct,
      wrong: wrong,
      estimatedMinutes: practice?.estimatedMinutes,
    );
  }

  int get answered => correct + wrong;

  int get remaining => total - answered;

  double get ratio => total == 0 ? 0 : answered / total;

  double get correctRatio => total == 0 ? 0 : correct / total;

  double get wrongRatio => total == 0 ? 0 : wrong / total;

  int get percent => (ratio * 100).round();

  TopicStatus get status {
    if (answered > 0 && wrong / answered > highErrorRatio) {
      return TopicStatus.needsReview;
    }
    if (ratio >= almostDoneRatio) return TopicStatus.almostDone;
    if (ratio < lowPracticeRatio) return TopicStatus.lowPractice;
    return TopicStatus.learning;
  }

  @override
  List<Object?> get props => [topic, total, correct, wrong, estimatedMinutes];
}

class TrackProgress extends Equatable {
  final List<TopicProgress> topics;

  const TrackProgress(this.topics);

  int get total => topics.fold(0, (sum, topic) => sum + topic.total);

  int get correct => topics.fold(0, (sum, topic) => sum + topic.correct);

  int get wrong => topics.fold(0, (sum, topic) => sum + topic.wrong);

  int get answered => correct + wrong;

  int get remaining => total - answered;

  double get ratio => total == 0 ? 0 : answered / total;

  double get correctRatio => total == 0 ? 0 : correct / total;

  double get wrongRatio => total == 0 ? 0 : wrong / total;

  int get percent => (ratio * 100).round();

  @override
  List<Object?> get props => [topics];
}

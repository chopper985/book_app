// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';

class QuizSet extends Equatable {
  final String id;
  final String trackId;
  final LocalizedText title;

  /// Question ids in display order.
  final List<String> questionIds;
  final int? durationMinutes;

  /// `null` means the set is free; otherwise the id of the plan that unlocks it.
  final String? accessPlanId;

  /// Generated per topic and level (see `ContentCatalog.withTopicSets`),
  /// not authored in `sets.json`. Hidden from set lists.
  final bool isGenerated;

  const QuizSet({
    required this.id,
    required this.trackId,
    required this.title,
    required this.questionIds,
    this.durationMinutes,
    this.accessPlanId,
    this.isGenerated = false,
  });

  bool get isFree => accessPlanId == null;

  bool get isTimed => durationMinutes != null;

  @override
  List<Object?> get props => [
        id,
        trackId,
        title,
        questionIds,
        durationMinutes,
        accessPlanId,
        isGenerated,
      ];
}

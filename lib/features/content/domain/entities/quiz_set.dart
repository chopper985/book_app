// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/content/domain/entities/localized_text.dart';

class QuizSet extends Equatable {
  final String id;
  final String trackId;
  final LocalizedText title;

  /// Question ids in display order.
  final List<String> questionIds;
  final int? durationMinutes;

  /// `null` means the set is free; otherwise the id of the plan that unlocks it.
  final String? accessPlanId;

  const QuizSet({
    required this.id,
    required this.trackId,
    required this.title,
    required this.questionIds,
    this.durationMinutes,
    this.accessPlanId,
  });

  bool get isFree => accessPlanId == null;

  bool get isTimed => durationMinutes != null;

  @override
  List<Object?> get props =>
      [id, trackId, title, questionIds, durationMinutes, accessPlanId];
}

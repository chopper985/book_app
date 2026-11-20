// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/question.dart';

/// A roadmap the learner follows up to one level (Junior covers Fresher and
/// Junior questions). Either a language roadmap (one track) or a position
/// roadmap (an option of a job position plus its core tracks).
class UserRoadmap extends Equatable {
  /// The track, or the main track of a position roadmap (for its icon).
  final String trackId;
  final QuestionLevel level;
  final DateTime addedAt;
  final String? positionId;
  final String? optionId;

  const UserRoadmap({
    required this.trackId,
    required this.level,
    required this.addedAt,
    this.positionId,
    this.optionId,
  });

  bool get isPosition => positionId != null;

  /// One roadmap per track (or position option) and level.
  String get id => isPosition
      ? positionIdOf(positionId!, optionId!, level)
      : idOf(trackId, level);

  static String idOf(String trackId, QuestionLevel level) =>
      '$trackId:${level.name}';

  static String positionIdOf(
    String positionId,
    String optionId,
    QuestionLevel level,
  ) =>
      'position:$positionId:$optionId:${level.name}';

  /// Levels included, easiest first.
  List<QuestionLevel> get levels =>
      QuestionLevel.values.where((l) => l.index <= level.index).toList();

  bool includes(QuestionLevel questionLevel) =>
      questionLevel.index <= level.index;

  @override
  List<Object?> get props => [trackId, level, addedAt, positionId, optionId];
}

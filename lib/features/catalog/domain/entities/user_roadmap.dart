// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/content/domain/entities/question.dart';

/// A roadmap the learner follows: one track up to one level. Picking Junior
/// covers Fresher and Junior questions.
class UserRoadmap extends Equatable {
  final String trackId;
  final QuestionLevel level;
  final DateTime addedAt;

  const UserRoadmap({
    required this.trackId,
    required this.level,
    required this.addedAt,
  });

  /// One roadmap per track and level.
  String get id => idOf(trackId, level);

  static String idOf(String trackId, QuestionLevel level) =>
      '$trackId:${level.name}';

  /// Levels included, easiest first.
  List<QuestionLevel> get levels =>
      QuestionLevel.values.where((l) => l.index <= level.index).toList();

  bool includes(QuestionLevel questionLevel) =>
      questionLevel.index <= level.index;

  @override
  List<Object?> get props => [trackId, level, addedAt];
}

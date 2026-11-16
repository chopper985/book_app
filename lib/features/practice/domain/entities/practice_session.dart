// Package imports:
import 'package:equatable/equatable.dart';

/// A practice run of one quiz set. Question order is frozen when the session
/// starts so a resumed session shows the same order.
class PracticeSession extends Equatable {
  final String id;
  final String setId;
  final String trackId;
  final List<String> questionIds;

  /// Selected option id per question id.
  final Map<String, String> answers;

  /// Questions the user flagged to review later.
  final Set<String> flagged;
  final int currentIndex;
  final DateTime startedAt;

  /// Deadline of a timed set, `null` when untimed.
  final DateTime? endsAt;

  const PracticeSession({
    required this.id,
    required this.setId,
    required this.trackId,
    required this.questionIds,
    required this.startedAt,
    this.answers = const {},
    this.flagged = const {},
    this.currentIndex = 0,
    this.endsAt,
  });

  String get currentQuestionId => questionIds[currentIndex];

  bool get isLastQuestion => currentIndex == questionIds.length - 1;

  PracticeSession copyWith({
    Map<String, String>? answers,
    Set<String>? flagged,
    int? currentIndex,
  }) {
    return PracticeSession(
      id: id,
      setId: setId,
      trackId: trackId,
      questionIds: questionIds,
      startedAt: startedAt,
      endsAt: endsAt,
      answers: answers ?? this.answers,
      flagged: flagged ?? this.flagged,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        setId,
        trackId,
        questionIds,
        answers,
        flagged,
        currentIndex,
        startedAt,
        endsAt,
      ];
}

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/domain/entities/track.dart';

/// Progress of one track inside a position roadmap, up to its level.
class PositionTrackProgress extends Equatable {
  final Track track;

  /// Part of the chosen option (vs shared core knowledge).
  final bool isMain;
  final int total;
  final int answered;

  const PositionTrackProgress({
    required this.track,
    required this.isMain,
    required this.total,
    required this.answered,
  });

  double get ratio => total == 0 ? 0 : answered / total;

  @override
  List<Object?> get props => [track, isMain, total, answered];
}

/// A position roadmap: tracks with progress and the mixed mock test pool.
class PositionDetail extends Equatable {
  final Position position;
  final PositionOption option;
  final QuestionLevel level;
  final List<PositionTrackProgress> tracks;

  /// Generated set with every question of the tracks up to [level].
  final String mockSetId;
  final List<String> mockQuestionIds;
  final bool mockIsPremium;
  final LearnerSummary learner;

  const PositionDetail({
    required this.position,
    required this.option,
    required this.level,
    required this.tracks,
    required this.mockSetId,
    required this.mockQuestionIds,
    required this.mockIsPremium,
    required this.learner,
  });

  int get total => tracks.fold(0, (sum, track) => sum + track.total);

  int get answered => tracks.fold(0, (sum, track) => sum + track.answered);

  double get ratio => total == 0 ? 0 : answered / total;

  @override
  List<Object?> get props => [
        position,
        option,
        level,
        tracks,
        mockSetId,
        mockQuestionIds,
        mockIsPremium,
        learner,
      ];
}

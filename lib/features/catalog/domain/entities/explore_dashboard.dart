// Package imports:
import 'package:equatable/equatable.dart';

class LearnerSummary extends Equatable {
  final String displayName;
  final String roleLabel;
  final String levelLabel;
  final int xp;
  final int streakDays;
  final int practicedCount;
  final int accuracyPercent;

  const LearnerSummary({
    required this.displayName,
    required this.roleLabel,
    required this.levelLabel,
    required this.xp,
    required this.streakDays,
    required this.practicedCount,
    required this.accuracyPercent,
  });

  @override
  List<Object?> get props => [
        displayName,
        roleLabel,
        levelLabel,
        xp,
        streakDays,
        practicedCount,
        accuracyPercent,
      ];
}

/// The unfinished session shown in the "Continue practice" hero.
class ContinueSession extends Equatable {
  final String setId;
  final String trackId;
  final int minutesAgo;
  final int answeredCount;

  const ContinueSession({
    required this.setId,
    required this.trackId,
    required this.minutesAgo,
    required this.answeredCount,
  });

  @override
  List<Object?> get props => [setId, trackId, minutesAgo, answeredCount];
}

class DailyChallenge extends Equatable {
  final String setId;
  final String title;
  final int rewardXp;

  const DailyChallenge({
    required this.setId,
    required this.title,
    required this.rewardXp,
  });

  @override
  List<Object?> get props => [setId, title, rewardXp];
}

/// Learner data shown on Explore. Mocked until progress is persisted (PR 3–4).
class ExploreDashboard extends Equatable {
  final LearnerSummary learner;
  final ContinueSession? continueSession;
  final DailyChallenge? dailyChallenge;

  /// Completed ratio (0..1) per track id.
  final Map<String, double> trackCompletion;

  const ExploreDashboard({
    required this.learner,
    required this.trackCompletion,
    this.continueSession,
    this.dailyChallenge,
  });

  @override
  List<Object?> get props =>
      [learner, continueSession, dailyChallenge, trackCompletion];
}

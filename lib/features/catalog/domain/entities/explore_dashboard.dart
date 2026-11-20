// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';

class LearnerSummary extends Equatable {
  final String displayName;

  /// Absolute path of the profile photo, `null` when none.
  final String? avatarPath;

  /// Drives the role label in the header; `null` without a profile.
  final ExperienceLevel? experience;

  /// Days until the interview, `null` when not set or already past.
  final int? daysToInterview;

  /// 1-based level derived from [xp].
  final int level;
  final int xp;
  final int streakDays;
  final int practicedCount;
  final int accuracyPercent;

  const LearnerSummary({
    required this.displayName,
    required this.experience,
    required this.level,
    required this.xp,
    required this.streakDays,
    required this.practicedCount,
    required this.accuracyPercent,
    this.daysToInterview,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [
        displayName,
        avatarPath,
        experience,
        daysToInterview,
        level,
        xp,
        streakDays,
        practicedCount,
        accuracyPercent,
      ];
}

/// The unfinished session shown in the "Continue practice" hero.
class ContinueSession extends Equatable {
  final String sessionId;
  final String setId;
  final String trackId;
  final int minutesAgo;
  final int answeredCount;

  /// Questions in the session (may be a subset of the set).
  final int totalQuestions;

  const ContinueSession({
    required this.sessionId,
    required this.setId,
    required this.trackId,
    required this.minutesAgo,
    required this.answeredCount,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props =>
      [sessionId, setId, trackId, minutesAgo, answeredCount, totalQuestions];
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

/// Learner data shown on Explore.
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

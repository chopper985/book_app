// Dart imports:
import 'dart:math';

// Package imports:
import 'package:equatable/equatable.dart';

/// Daily allowance of each plan. One session = one attempt at a set,
/// retries included.
class PremiumPlans {
  const PremiumPlans._();

  static const int freeDailySessions = 3;
  static const int premiumDailySessions = 10;

  /// Sessions in an extra-session pack when the product id has no number
  /// (`practice_sessions_10` gives 10).
  static const int defaultPackSessions = 10;
}

/// What the learner can still practise today.
class PracticeQuota extends Equatable {
  final bool isPremium;
  final int usedToday;

  /// Extra sessions bought and not used yet; they never expire.
  final int extraSessions;
  final DateTime? premiumExpiresAt;

  const PracticeQuota({
    this.isPremium = false,
    this.usedToday = 0,
    this.extraSessions = 0,
    this.premiumExpiresAt,
  });

  int get dailyLimit => isPremium
      ? PremiumPlans.premiumDailySessions
      : PremiumPlans.freeDailySessions;

  int get remainingToday => max(0, dailyLimit - usedToday);

  bool get canStart => remainingToday > 0 || extraSessions > 0;

  @override
  List<Object?> get props =>
      [isPremium, usedToday, extraSessions, premiumExpiresAt];
}

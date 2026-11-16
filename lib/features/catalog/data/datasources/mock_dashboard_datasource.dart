// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_learning.dart';
import 'package:AppName/features/content/domain/entities/localized_text.dart';

/// MOCK: fixed learner data matching the Figma design. Replace with real
/// progress once sessions and results are persisted (PR 3–4).
@lazySingleton
class MockDashboardDataSource {
  static const LearnerSummary _learner = LearnerSummary(
    displayName: 'Minh',
    roleLabel: 'Junior Dev',
    levelLabel: 'Junior Lv.2',
    xp: 1420,
    streakDays: 5,
    practicedCount: 142,
    accuracyPercent: 78,
  );

  ExploreDashboard load() {
    return const ExploreDashboard(
      learner: _learner,
      continueSession: ContinueSession(
        setId: 'flutter.set.basic',
        trackId: 'flutter',
        minutesAgo: 12,
        answeredCount: 3,
      ),
      dailyChallenge: DailyChallenge(
        setId: 'flutter.set.junior',
        title: 'Flutter: Lifecycle, State & Form',
        rewardXp: 50,
      ),
      trackCompletion: {
        'flutter': 0.58,
        'dart': 0.82,
        'react_ts': 0.24,
        'dotnet': 0.12,
        'go': 0.40,
        'rust': 0.05,
      },
    );
  }

  /// MOCK: track detail learner data (progress ratios match the Figma
  /// "Lộ trình Flutter - Chi tiết chủ đề" screen).
  TrackLearning loadTrackLearning(String trackId) {
    return TrackLearning(
      learner: _learner,
      versionLabel: _versionLabels[trackId],
      topicPractice: _topicPractice[trackId] ?? const {},
      dailySnippet: _dailySnippets[trackId],
    );
  }

  static const Map<String, String> _versionLabels = {
    'flutter': 'Dart 3.x',
    'dart': 'Dart 3.x',
  };

  static const Map<String, Map<String, TopicPractice>> _topicPractice = {
    'flutter': {
      'widget': TopicPractice(
        correctRatio: 0.72,
        wrongRatio: 0.08,
        estimatedMinutes: 8,
      ),
      'state': TopicPractice(
        correctRatio: 0.37,
        wrongRatio: 0.1,
        estimatedMinutes: 25,
      ),
      'lifecycle': TopicPractice(correctRatio: 0.28, wrongRatio: 0.2),
      'layout': TopicPractice(correctRatio: 0.28, wrongRatio: 0.02),
    },
    'dart': {
      'null_safety': TopicPractice(
        correctRatio: 0.5,
        wrongRatio: 0.5,
        estimatedMinutes: 6,
      ),
      'collections': TopicPractice(
        correctRatio: 1,
        wrongRatio: 0,
        estimatedMinutes: 4,
      ),
    },
  };

  static const Map<String, DailySnippet> _dailySnippets = {
    'flutter': DailySnippet(
      code:
          'const SizedBox(width: 0, height: 0)\n// vs\nconst SizedBox.shrink()',
      question: LocalizedText({
        'vi': 'Có sự khác biệt hiệu năng render không?',
        'en': 'Is there any rendering performance difference?',
      }),
      rewardXp: 20,
    ),
    'dart': DailySnippet(
      code:
          "final a = const [1, 2];\nfinal b = const [1, 2];\nprint(identical(a, b));",
      question: LocalizedText({
        'vi': 'Kết quả in ra là gì?',
        'en': 'What does this print?',
      }),
      rewardXp: 20,
    ),
  };
}

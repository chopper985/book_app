// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_learning.dart';
import 'package:AppName/features/content/domain/entities/localized_text.dart';

/// MOCK: learner identity and editorial content that have no real source
/// yet. Statistics come from practice history (see `LearnerProgress`); the
/// name and role move to the onboarding profile.
@lazySingleton
class MockDashboardDataSource {
  String get displayName => 'Minh';

  String get roleLabel => 'Junior Dev';

  DailyChallenge get dailyChallenge => const DailyChallenge(
        setId: 'flutter.set.junior',
        title: 'Flutter: Lifecycle, State & Form',
        rewardXp: 50,
      );

  String? versionLabel(String trackId) => _versionLabels[trackId];

  DailySnippet? dailySnippet(String trackId) => _dailySnippets[trackId];

  static const Map<String, String> _versionLabels = {
    'flutter': 'Dart 3.x',
    'dart': 'Dart 3.x',
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

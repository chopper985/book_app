// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/analytics/app_firebase.dart';

/// How a practice session was opened.
enum PracticeMode {
  /// Every question of the set.
  full,

  /// A subset: mistakes review or quick practice.
  subset,

  /// An unfinished session reopened.
  resume,
}

/// Product events. Parameters never include personal data (name, email,
/// phone, free text); ids are content ids such as `flutter.set.basic`.
abstract class AppAnalytics {
  Future<void> screenView(String screenName);

  Future<void> onboardingCompleted({
    required String role,
    required String experience,
    required int stackSize,
    required bool hasInterviewDate,
  });

  Future<void> practiceStarted({
    required String trackId,
    required String setId,
    required PracticeMode mode,
    required int questionCount,
  });

  Future<void> practiceSubmitted({
    required String trackId,
    required String setId,
    required int scorePercent,
    required int questionCount,
    required int durationSeconds,
    required bool timedOut,
  });

  Future<void> trackSaved({required String trackId, required bool saved});

  Future<void> profileUpdated({
    required bool avatarChanged,
    required String experience,
  });

  Future<void> progressReset();

  Future<void> languageChanged(String languageCode);

  /// Segments users in reports, e.g. `experience = junior`.
  Future<void> setUserProperty(String name, String? value);
}

@LazySingleton(as: AppAnalytics)
class FirebaseAppAnalytics implements AppAnalytics {
  String? _lastScreen;

  FirebaseAnalytics? get _analytics =>
      AppFirebase.isReady ? FirebaseAnalytics.instance : null;

  Future<void> _log(String name, Map<String, Object> parameters) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (error) {
      debugPrint('Analytics event $name failed: $error');
    }
  }

  @override
  Future<void> screenView(String screenName) async {
    if (screenName == _lastScreen) return;
    _lastScreen = screenName;
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await analytics.logScreenView(screenName: screenName);
    } catch (error) {
      debugPrint('Analytics screen view failed: $error');
    }
  }

  @override
  Future<void> onboardingCompleted({
    required String role,
    required String experience,
    required int stackSize,
    required bool hasInterviewDate,
  }) =>
      _log('onboarding_completed', {
        'role': role,
        'experience': experience,
        'stack_size': stackSize,
        'has_interview_date': hasInterviewDate ? 1 : 0,
      });

  @override
  Future<void> practiceStarted({
    required String trackId,
    required String setId,
    required PracticeMode mode,
    required int questionCount,
  }) =>
      _log('practice_started', {
        'track_id': trackId,
        'set_id': setId,
        'mode': mode.name,
        'question_count': questionCount,
      });

  @override
  Future<void> practiceSubmitted({
    required String trackId,
    required String setId,
    required int scorePercent,
    required int questionCount,
    required int durationSeconds,
    required bool timedOut,
  }) =>
      _log('practice_submitted', {
        'track_id': trackId,
        'set_id': setId,
        'score_percent': scorePercent,
        'question_count': questionCount,
        'duration_seconds': durationSeconds,
        'timed_out': timedOut ? 1 : 0,
      });

  @override
  Future<void> trackSaved({required String trackId, required bool saved}) =>
      _log(saved ? 'track_saved' : 'track_unsaved', {'track_id': trackId});

  @override
  Future<void> profileUpdated({
    required bool avatarChanged,
    required String experience,
  }) =>
      _log('profile_updated', {
        'avatar_changed': avatarChanged ? 1 : 0,
        'experience': experience,
      });

  @override
  Future<void> progressReset() => _log('progress_reset', {});

  @override
  Future<void> languageChanged(String languageCode) =>
      _log('language_changed', {'language': languageCode});

  @override
  Future<void> setUserProperty(String name, String? value) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await analytics.setUserProperty(name: name, value: value);
    } catch (error) {
      debugPrint('Analytics user property $name failed: $error');
    }
  }
}

/// Does nothing; the default in tests.
class NoopAppAnalytics implements AppAnalytics {
  const NoopAppAnalytics();

  @override
  Future<void> screenView(String screenName) async {}

  @override
  Future<void> onboardingCompleted({
    required String role,
    required String experience,
    required int stackSize,
    required bool hasInterviewDate,
  }) async {}

  @override
  Future<void> practiceStarted({
    required String trackId,
    required String setId,
    required PracticeMode mode,
    required int questionCount,
  }) async {}

  @override
  Future<void> practiceSubmitted({
    required String trackId,
    required String setId,
    required int scorePercent,
    required int questionCount,
    required int durationSeconds,
    required bool timedOut,
  }) async {}

  @override
  Future<void> trackSaved({required String trackId, required bool saved}) async {}

  @override
  Future<void> profileUpdated({
    required bool avatarChanged,
    required String experience,
  }) async {}

  @override
  Future<void> progressReset() async {}

  @override
  Future<void> languageChanged(String languageCode) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}
}

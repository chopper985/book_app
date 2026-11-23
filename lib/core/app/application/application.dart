// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_analytics.dart';
import 'package:interview_practice/core/app/languages/service/service.dart';
import 'package:interview_practice/core/injection/injection_container.dart';
import 'package:interview_practice/core/utils/datasources/base_local_data.dart';
import 'package:interview_practice/features/auth/domain/repositories/auth_repository.dart';
import 'package:interview_practice/features/premium/domain/usecase/premium_usecases.dart';
import 'package:interview_practice/features/profile/domain/repositories/profile_repository.dart';
import 'package:interview_practice/features/sync/domain/usecase/learner_sync.dart';

class Application {
  /// [Production - Dev]
  static Future<void> initialAppLication() async {
    try {
      // Config local storage
      await BaseLocalData.initialBox();

      configureDependencies();
      _setAnalyticsUserProperties();
      _startAccount();

      FlutterNativeSplash.remove();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  /// Segments analytics by profile and language from the first event.
  static void _setAnalyticsUserProperties() {
    final analytics = getIt<AppAnalytics>();
    final profile = getIt<ProfileRepository>().profile;
    analytics
      ..setUserProperty('language', LanguageService().getLocale().langCode)
      ..setUserProperty('role', profile?.role.name)
      ..setUserProperty('experience', profile?.experience.name);
  }

  /// Every install gets an anonymous Firebase account in the background (to
  /// link Google/phone later), and linked accounts start syncing.
  static void _startAccount() {
    getIt<LearnerSync>().start();
    getIt<PurchaseIdentity>().start();
    unawaited(getIt<AuthRepository>().ensureSignedIn());
  }

  ///Singleton factory
  static final Application _instance = Application._internal();

  factory Application() {
    return _instance;
  }

  Application._internal();
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Project imports:
import 'package:AppName/core/analytics/app_analytics.dart';
import 'package:AppName/core/app/languages/service/service.dart';
import 'package:AppName/core/injection/injection_container.dart';
import 'package:AppName/core/utils/datasources/base_local_data.dart';
import 'package:AppName/features/profile/domain/repositories/profile_repository.dart';

class Application {
  /// [Production - Dev]
  static Future<void> initialAppLication() async {
    try {
      // Config local storage
      await BaseLocalData.initialBox();

      configureDependencies();
      _setAnalyticsUserProperties();

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

  ///Singleton factory
  static final Application _instance = Application._internal();

  factory Application() {
    return _instance;
  }

  Application._internal();
}

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Starts Firebase from the native config (`google-services.json` on
/// Android, `GoogleService-Info.plist` on iOS). The app keeps working when
/// the config is missing: analytics and crash reports are then skipped.
class AppFirebase {
  const AppFirebase._();

  static bool _ready = false;

  static bool get isReady => _ready;

  /// Data is collected in release/profile builds only, so debugging does not
  /// pollute the dashboards.
  static bool get collectionEnabled => !kDebugMode;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (error) {
      debugPrint('Firebase disabled: $error');
      return;
    }
    _ready = true;

    final crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(collectionEnabled);
    await FirebaseAnalytics.instance
        .setAnalyticsCollectionEnabled(collectionEnabled);

    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      previousOnError?.call(details);
      crashlytics.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// For errors caught by the root zone.
  static void recordError(Object error, StackTrace stack) {
    debugPrint('Uncaught error: $error');
    if (_ready) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  }
}

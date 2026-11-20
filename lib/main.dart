// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:i18n_extension/i18n_extension.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_firebase.dart';
import 'package:interview_practice/core/app/application/application.dart';
import 'package:interview_practice/core/app/languages/service/service.dart';
import 'package:interview_practice/core/app/themes/data/app_themes.dart';
import 'package:interview_practice/features/app/app.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      final WidgetsBinding widgetsBinding =
          WidgetsFlutterBinding.ensureInitialized();
      // Keep native splash screen up until app is finished bootstrapping
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      // The Android launch theme is fullscreen; bring the system bars back
      // and draw edge to edge with light icons over the dark UI.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlayStyle);

      // Before anything else, so startup errors reach Crashlytics.
      await AppFirebase.initialize();
      await Application.initialAppLication();

      runApp(
        I18n(
          initialLocale: LanguageService().getLocale().locale,
          child: const App(),
        ),
      );
    },
    AppFirebase.recordError,
  );
}

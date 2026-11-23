// Flutter imports:
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';

/// The app ships a single dark theme (IDE slate style from Figma).
class AppTheme {
  AppTheme({required this.data});

  final ThemeData data;

  /// Dark-only app: transparent status bar with light icons, and a navigation
  /// bar matching the bottom nav. `statusBarBrightness` is the iOS setting.
  static const SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppPalette.surfaceLowest,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  factory AppTheme.dark() {
    final themeData = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppPalette.colorScheme,
      scaffoldBackgroundColor: AppPalette.surface,
      canvasColor: AppPalette.surface,
      cardColor: AppPalette.surfaceLow,
      fontFamily: AppText.sansFamily,
      pageTransitionsTheme: kIsWeb
          ? null
          : const PageTransitionsTheme(
              builders: {
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              },
            ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppPalette.surfaceHighest,
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppPalette.surfaceContainer,
        elevation: 0,
        modalElevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        surfaceTintColor: AppPalette.surfaceLowest,
        backgroundColor: AppPalette.surfaceLowest,
        iconTheme: IconThemeData(color: AppPalette.onSurface),
        systemOverlayStyle: systemOverlayStyle,
      ),
      dividerTheme: const DividerThemeData(
        color: AppPalette.surfaceHighest,
        space: 0,
        thickness: 1,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppPalette.surfaceContainer,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppPalette.primary,
      ),
    );
    return AppTheme(data: themeData);
  }
}

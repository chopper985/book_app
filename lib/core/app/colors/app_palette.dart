// Flutter imports:
import 'package:flutter/material.dart';

/// Dark "IDE slate" palette from the Figma design (DevInterview).
class AppPalette {
  const AppPalette._();

  // Surfaces, darkest to lightest.
  static const Color surfaceLowest = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF10141A);
  static const Color surfaceLow = Color(0xFF181C22);
  static const Color surfaceContainer = Color(0xFF1C2026);
  static const Color surfaceHigh = Color(0xFF262A31);
  static const Color surfaceHighest = Color(0xFF31353C);
  static const Color surfaceBright = Color(0xFF353940);

  // Text.
  static const Color onSurface = Color(0xFFDFE2EB);
  static const Color onSurfaceVariant = Color(0xFFBDC8D1);

  // Accents.
  static const Color primary = Color(0xFF8ED5FF);
  static const Color primaryStrong = Color(0xFF38BDF8);
  static const Color onPrimaryStrong = Color(0xFF004965);
  static const Color teal = Color(0xFF44E2CD);
  static const Color tealDeep = Color(0xFF3CDDC7);
  static const Color tealContainer = Color(0x3303C6B2);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0x26FFB4AB);
  static const Color errorStrong = Color(0xFF93000A);
  static const Color onErrorStrong = Color(0xFFFFDAD6);
  static const Color purple = Color(0xFFE1BFFF);
  static const Color purpleDeep = Color(0xFFCE9BFF);
  static const Color purpleContainer = Color(0x33CE9BFF);
  static const Color primaryContainer = Color(0x2638BDF8);

  static const LinearGradient progressGradient = LinearGradient(
    colors: [primary, teal],
  );

  static const ColorScheme colorScheme = ColorScheme.dark(
    surface: surface,
    surfaceContainerLowest: surfaceLowest,
    surfaceContainerLow: surfaceLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceHigh,
    surfaceContainerHighest: surfaceHighest,
    surfaceBright: surfaceBright,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    primary: primary,
    onPrimary: onPrimaryStrong,
    primaryContainer: primaryStrong,
    onPrimaryContainer: onPrimaryStrong,
    secondary: teal,
    onSecondary: surface,
    tertiary: purple,
    error: error,
    errorContainer: errorContainer,
    onErrorContainer: error,
    outlineVariant: surfaceHighest,
  );
}

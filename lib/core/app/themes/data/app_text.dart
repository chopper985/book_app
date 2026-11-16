// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';

/// Text styles of the design. Sizes and line heights are Figma px.
class AppText {
  const AppText._();

  static const String sansFamily = 'BeVietnamPro';
  static const String monoFamily = 'JetBrainsMono';

  /// Be Vietnam Pro: headings and body copy.
  static TextStyle sans(
    double size, {
    double? height,
    FontWeight weight = FontWeight.w400,
    Color color = AppPalette.onSurface,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: sansFamily,
        fontSize: size.dsp,
        height: height == null ? null : height / size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing?.dsp,
      );

  /// JetBrains Mono: labels, numbers, badges and code.
  static TextStyle mono(
    double size, {
    double? height,
    FontWeight weight = FontWeight.w600,
    Color color = AppPalette.onSurfaceVariant,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: monoFamily,
        fontSize: size.dsp,
        height: height == null ? null : height / size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing?.dsp,
      );
}

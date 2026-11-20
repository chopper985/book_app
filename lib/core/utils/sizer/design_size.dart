// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:sizer/sizer.dart';

/// Converts a size measured in the Figma frame (390 × 844) to `.sp`.
///
/// sizer's `x.sp` grows roughly with `x² * (height + width) / 20800`, so
/// `40.sp` is ~96px on a phone. This picks the `.sp` input that lands on the
/// Figma value on the design frame and scales linearly with the screen
/// everywhere else: `16.dsp` ≈ 16px on a 390 × 844 phone.
extension DesignSize on num {
  static const double _designFactor = 20800 / (390 + 844);

  /// Keeps the sign so negative values (e.g. letterSpacing) don't become NaN.
  double get dsp => sign * math.sqrt(abs() * _designFactor).sp;
}

// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Radial score chart (Progress Visualization): correct / graded.
class ResultScoreRing extends StatelessWidget {
  final int correct;
  final int graded;
  final double ratio;
  final int percent;

  const ResultScoreRing({
    super.key,
    required this.correct,
    required this.graded,
    required this.ratio,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 144.dsp,
      child: CustomPaint(
        painter: _RingPainter(
          ratio: ratio,
          stroke: 12.dsp,
          inset: 12.dsp,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(28.dsp),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$correct/$graded',
                    style:
                        AppText.sans(24, height: 32, weight: FontWeight.w700),
                  ),
                  Text(
                    Strings.resultPassedPercent.i18n.fill([percent]),
                    style: AppText.mono(
                      10,
                      height: 14,
                      color: AppPalette.teal,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double ratio;
  final double stroke;
  final double inset;

  _RingPainter({
    required this.ratio,
    required this.stroke,
    required this.inset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(inset);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppPalette.surfaceHighest;
    canvas.drawOval(arcRect, track);

    final value = ratio.clamp(0.0, 1.0);
    if (value == 0) return;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppPalette.teal;
    canvas.drawArc(arcRect, -math.pi / 2, 2 * math.pi * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.ratio != ratio ||
      oldDelegate.stroke != stroke ||
      oldDelegate.inset != inset;
}

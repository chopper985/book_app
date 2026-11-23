// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// One bar segment: a share (0..1) of the track and its fill.
class ProgressSegment {
  final double value;
  final Color color;

  const ProgressSegment(this.value, this.color);
}

/// Progress track with consecutive colored segments (e.g. correct + wrong).
class SegmentedProgressBar extends StatelessWidget {
  final List<ProgressSegment> segments;
  final double height;
  final Color trackColor;

  const SegmentedProgressBar({
    super.key,
    required this.segments,
    this.height = 6,
    this.trackColor = AppPalette.surfaceHighest,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.dsp);
    var remaining = 1.0;
    final widths = <double>[];
    for (final segment in segments) {
      final value = segment.value.clamp(0.0, remaining);
      widths.add(value);
      remaining -= value;
    }

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height.dsp,
        color: trackColor,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              for (var i = 0; i < segments.length; i++)
                Container(
                  width: constraints.maxWidth * widths[i],
                  color: segments[i].color,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

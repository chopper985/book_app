// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Rounded progress track. Uses [gradient] when given, otherwise [color].
class AppProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color trackColor;
  final Color color;
  final Gradient? gradient;

  /// Gap between the track edge and the fill, in Figma px.
  final double inset;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.trackColor = AppPalette.surfaceHigh,
    this.color = AppPalette.primary,
    this.gradient,
    this.inset = 0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.dsp);
    return Container(
      height: height.dsp,
      padding: EdgeInsets.all(inset == 0 ? 0 : inset.dsp),
      decoration: BoxDecoration(color: trackColor, borderRadius: radius),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1).toDouble(),
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: gradient == null ? color : null,
            gradient: gradient,
            borderRadius: radius,
          ),
        ),
      ),
    );
  }
}

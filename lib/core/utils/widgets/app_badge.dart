// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Small mono label on a tinted background.
class AppBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final double fontSize;
  final double lineHeight;
  final EdgeInsets padding;
  final double radius;
  final bool uppercase;

  const AppBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.fontSize = 10,
    this.lineHeight = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.radius = 6,
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        padding.left.dsp,
        padding.top.dsp,
        padding.right.dsp,
        padding.bottom.dsp,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius.dsp),
      ),
      child: Text(
        uppercase ? label.toUpperCase() : label,
        style: AppText.mono(fontSize, height: lineHeight, color: foreground),
      ),
    );
  }
}

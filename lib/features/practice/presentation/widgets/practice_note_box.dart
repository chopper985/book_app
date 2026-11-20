// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Icon + text panel: the tip box of the design, also used for the
/// self-explain instructions.
class PracticeNoteBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? label;
  final String text;
  final Color background;

  const PracticeNoteBox({
    super.key,
    required this.icon,
    required this.text,
    this.label,
    this.iconColor = AppPalette.onSurfaceVariant,
    this.background = AppPalette.surfaceLow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.dsp),
            child: Icon(icon, size: 16.dsp, color: iconColor),
          ),
          SizedBox(width: 12.dsp),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  if (label != null)
                    TextSpan(
                      text: label,
                      style: const TextStyle(
                        color: AppPalette.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  TextSpan(text: text),
                ],
              ),
              style: AppText.sans(
                13,
                height: 20,
                color: AppPalette.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

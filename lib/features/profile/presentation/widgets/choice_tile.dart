// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Selectable card with a title, optional hint and a check mark, in the style
/// of the practice option tiles.
class ChoiceTile extends StatelessWidget {
  final String title;
  final String? hint;
  final Widget? leading;
  final bool selected;
  final VoidCallback onTap;

  const ChoiceTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.hint,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppPalette.primaryContainer : AppPalette.surfaceLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 56.dsp),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.dsp,
                vertical: 12.dsp,
              ),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: 12.dsp),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppText.sans(
                            15,
                            height: 22,
                            weight: FontWeight.w600,
                            color: selected
                                ? AppPalette.primary
                                : AppPalette.onSurface,
                          ),
                        ),
                        if (hint != null) ...[
                          SizedBox(height: 2.dsp),
                          Text(
                            hint!,
                            style: AppText.sans(
                              12,
                              height: 16,
                              color: AppPalette.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.dsp),
                  Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    size: 20.dsp,
                    color: selected
                        ? AppPalette.primaryStrong
                        : AppPalette.surfaceBright,
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

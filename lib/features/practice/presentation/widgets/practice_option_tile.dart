// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';

/// Answer option card. Selected: tinted, left accent bar and check.
class PracticeOptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const PracticeOptionTile({
    super.key,
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Semantics(
      selected: selected,
      button: true,
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: selected
              ? AppPalette.primaryStrong.withValues(alpha: 0.15)
              : AppPalette.surfaceContainer,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: selected
                        ? AppPalette.primaryStrong
                        : Colors.transparent,
                    width: 4.dsp,
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(12.dsp, 16.dsp, 16.dsp, 16.dsp),
              child: Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minWidth: 32.dsp,
                      minHeight: 32.dsp,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppPalette.primaryStrong
                          : AppPalette.surfaceHigh,
                      borderRadius: BorderRadius.circular(4.dsp),
                    ),
                    child: Text(
                      letter,
                      style: AppText.mono(
                        12,
                        height: 16,
                        weight: FontWeight.w700,
                        color: selected
                            ? AppPalette.onPrimaryStrong
                            : AppPalette.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.dsp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: AppText.mono(
                            12,
                            height: 18,
                            weight: FontWeight.w500,
                            color: selected
                                ? AppPalette.primary
                                : AppPalette.onSurface,
                          ),
                        ),
                        if (selected) ...[
                          SizedBox(height: 2.dsp),
                          Text(
                            Strings.practiceSelected.i18n,
                            style: AppText.mono(
                              10,
                              height: 14,
                              color: AppPalette.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 12.dsp),
                  Container(
                    width: 20.dsp,
                    height: 20.dsp,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppPalette.primaryStrong
                          : AppPalette.surfaceHighest,
                      shape: BoxShape.circle,
                    ),
                    child: selected
                        ? Icon(
                            Icons.check,
                            size: 14.dsp,
                            color: AppPalette.onPrimaryStrong,
                          )
                        : null,
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

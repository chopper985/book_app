// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';

/// Section 2: "review mistakes" CTA and secondary navigation.
class ResultActions extends StatelessWidget {
  final int mistakeCount;
  final VoidCallback onReviewMistakes;
  final VoidCallback onExplore;
  final VoidCallback onRetrySet;

  const ResultActions({
    super.key,
    required this.mistakeCount,
    required this.onReviewMistakes,
    required this.onExplore,
    required this.onRetrySet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (mistakeCount > 0) ...[
          _ReviewButton(count: mistakeCount, onTap: onReviewMistakes),
          SizedBox(height: 8.dsp),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SecondaryButton(
                icon: const AppSvg(
                  'assets/figma/result/explore.svg',
                  width: 13.33,
                  height: 13.33,
                  color: AppPalette.primary,
                ),
                label: Strings.resultExplore.i18n,
                onTap: onExplore,
              ),
            ),
            SizedBox(width: 8.dsp),
            Expanded(
              child: _SecondaryButton(
                icon: const AppSvg(
                  'assets/figma/result/play.svg',
                  width: 7.33,
                  height: 9.33,
                ),
                label: Strings.resultRetrySet.i18n,
                onTap: onRetrySet,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ReviewButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Material(
      color: AppPalette.errorStrong,
      borderRadius: radius,
      elevation: 2,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 48.dsp),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.dsp, vertical: 8.dsp),
            child: Row(
              children: [
                const AppSvg(
                  'assets/figma/result/review.svg',
                  width: 18.33,
                  height: 13.33,
                  color: AppPalette.onErrorStrong,
                ),
                SizedBox(width: 8.dsp),
                Expanded(
                  child: Text(
                    Strings.resultReviewMistakes.i18n.fill([count]),
                    style: AppText.sans(
                      16,
                      height: 24,
                      weight: FontWeight.w600,
                      color: AppPalette.onErrorStrong,
                    ),
                  ),
                ),
                SizedBox(width: 8.dsp),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.dsp,
                    vertical: 2.dsp,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(6.dsp),
                  ),
                  child: Text(
                    Strings.resultMistakeBadge.i18n.fill([count]),
                    style: AppText.mono(
                      10,
                      height: 14,
                      color: AppPalette.onErrorStrong,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Material(
      color: AppPalette.surfaceHigh,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 44.dsp),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.dsp, vertical: 8.dsp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                SizedBox(width: 6.dsp),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppText.sans(14, height: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

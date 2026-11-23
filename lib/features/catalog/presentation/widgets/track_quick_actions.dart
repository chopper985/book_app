// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_badge.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// "Mega CTA Button: Random N Questions".
class RandomPracticeButton extends StatelessWidget {
  final int questionCount;
  final String subtitle;
  final VoidCallback onTap;

  const RandomPracticeButton({
    super.key,
    required this.questionCount,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Material(
      color: AppPalette.primaryStrong,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 56.dsp),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.dsp, vertical: 11.dsp),
            child: Row(
              children: [
                Container(
                  width: 32.dsp,
                  height: 32.dsp,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppPalette.onPrimaryStrong.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.dsp),
                  ),
                  child: AppSvg(
                    Assets.figma.result.levelBolt,
                    width: 15.26,
                    height: 19.08,
                    color: AppPalette.onPrimaryStrong,
                  ),
                ),
                SizedBox(width: 8.dsp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.trackQuickRandomTitle.i18n
                            .fill([questionCount]),
                        style: AppText.sans(
                          15,
                          height: 20,
                          weight: FontWeight.w700,
                          color: AppPalette.onPrimaryStrong,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppText.mono(
                          10,
                          height: 14,
                          weight: FontWeight.w500,
                          color:
                              AppPalette.onPrimaryStrong.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.dsp),
                Container(
                  width: 32.dsp,
                  height: 32.dsp,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppPalette.onPrimaryStrong,
                    borderRadius: BorderRadius.circular(8.dsp),
                  ),
                  child: AppSvg(
                    Assets.figma.explore.icPlay,
                    width: 9.17,
                    height: 11.67,
                    color: AppPalette.primaryStrong,
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

/// "Secondary Interactive CTA: Timed Mock".
class TimedMockCard extends StatelessWidget {
  final int durationMinutes;
  final int questionCount;
  final VoidCallback onStart;

  const TimedMockCard({
    super.key,
    required this.durationMinutes,
    required this.questionCount,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Row(
        children: [
          Container(
            width: 36.dsp,
            height: 40.dsp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.surfaceHigh,
              borderRadius: BorderRadius.circular(6.dsp),
            ),
            child: AppSvg(
              Assets.figma.result.timer,
              width: 15,
              height: 17.5,
              color: AppPalette.teal,
            ),
          ),
          SizedBox(width: 12.dsp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.dsp,
                  runSpacing: 2.dsp,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      Strings.trackTimedTitle.i18n,
                      style: AppText.sans(
                        16,
                        height: 24,
                        weight: FontWeight.w600,
                      ),
                    ),
                    AppBadge(
                      label: Strings.trackTimedMinutes.i18n
                          .fill([durationMinutes]),
                      background: AppPalette.tealContainer,
                      foreground: AppPalette.teal,
                      radius: 4,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ),
                  ],
                ),
                Text(
                  Strings.trackTimedSubtitle.i18n.fill([questionCount]),
                  style: AppText.sans(
                    12,
                    height: 18,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.dsp),
          Material(
            color: AppPalette.surfaceHigh,
            borderRadius: BorderRadius.circular(8.dsp),
            child: InkWell(
              onTap: onStart,
              borderRadius: BorderRadius.circular(8.dsp),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 48.dsp),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.dsp),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Strings.trackStart.i18n,
                        style: AppText.mono(
                          12,
                          height: 16,
                          weight: FontWeight.w700,
                          color: AppPalette.primary,
                        ),
                      ),
                      SizedBox(width: 6.dsp),
                      AppSvg(
                        Assets.figma.explore.icArrowRight,
                        width: 9.33,
                        height: 9.33,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

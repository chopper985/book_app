// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';
import 'package:AppName/gen/assets.gen.dart';

class DailyChallengeCard extends StatelessWidget {
  final String title;
  final int rewardXp;
  final int streakDays;
  final VoidCallback onSolve;

  const DailyChallengeCard({
    super.key,
    required this.title,
    required this.rewardXp,
    required this.streakDays,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSvg(
                      Assets.figma.explore.icSparkle,
                      width: 14.67,
                      height: 14.67,
                    ),
                    SizedBox(width: 6.dsp),
                    Expanded(
                      child: Text(
                        Strings.dailyChallenge.i18n.toUpperCase(),
                        style: AppText.mono(
                          10,
                          height: 14,
                          color: AppPalette.teal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.dsp),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(16, height: 24, weight: FontWeight.w600),
                ),
                SizedBox(height: 2.dsp),
                Text(
                  Strings.dailyReward.i18n.fill([rewardXp, streakDays]),
                  style: AppText.sans(
                    12,
                    height: 18,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.dsp),
          Material(
            color: AppPalette.surfaceHighest,
            borderRadius: BorderRadius.circular(8.dsp),
            child: InkWell(
              onTap: onSolve,
              borderRadius: BorderRadius.circular(8.dsp),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.dsp,
                  vertical: 8.dsp,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Strings.solveNow.i18n,
                      style: AppText.mono(
                        12,
                        height: 16,
                        color: AppPalette.teal,
                      ),
                    ),
                    SizedBox(width: 4.dsp),
                    AppSvg(
                      Assets.figma.explore.icChevronRight,
                      width: 4.32,
                      height: 7,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

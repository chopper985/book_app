// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/gen/assets.gen.dart';

/// Greeting and quick stats ("Top Greeting & Live Stats Bento").
class ExploreGreeting extends StatelessWidget {
  final LearnerSummary learner;

  const ExploreGreeting({super.key, required this.learner});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8.dsp,
              height: 8.dsp,
              decoration: const BoxDecoration(
                color: AppPalette.teal,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4.dsp),
            Expanded(
              child: Text(
                Strings.sessionActive.i18n,
                style: AppText.mono(
                  10,
                  height: 14,
                  color: AppPalette.teal,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.dsp, vertical: 4.dsp),
              decoration: BoxDecoration(
                color: AppPalette.surfaceHigh,
                borderRadius: BorderRadius.circular(8.dsp),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSvg(
                    Assets.figma.explore.icStreak,
                    width: 9.33,
                    height: 10.5,
                  ),
                  SizedBox(width: 6.dsp),
                  Text(
                    Strings.streakDays.i18n.fill([learner.streakDays]),
                    style: AppText.mono(
                      12,
                      height: 16,
                      color: AppPalette.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.dsp),
        Text(
          Strings.greeting.i18n.fill([learner.displayName]),
          style: AppText.sans(
            24,
            height: 32,
            weight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 2.dsp),
        Text(
          Strings.greetingSubtitle.i18n,
          style: AppText.sans(
            14,
            height: 20,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12.dsp),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Assets.figma.explore.icLevel,
                  iconSize: const Size(8.33, 16.67),
                  label: Strings.currentLevel.i18n,
                  value: Strings.levelValue.i18n.fill([
                    learner.levelLabel,
                    _formatXp(learner.xp),
                  ]),
                ),
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: _StatTile(
                  icon: Assets.figma.explore.icPracticed,
                  iconSize: const Size(16.67, 16.67),
                  label: Strings.practiced.i18n,
                  value: Strings.practicedValue.i18n.fill([
                    learner.practicedCount,
                    learner.accuracyPercent,
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatXp(int xp) => xp
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}

class _StatTile extends StatelessWidget {
  final String icon;
  final Size iconSize;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.iconSize,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLow,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Row(
        children: [
          Container(
            width: 34.dsp,
            constraints: BoxConstraints(minHeight: 40.dsp),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.surfaceHigh,
              borderRadius: BorderRadius.circular(4.dsp),
            ),
            child: AppSvg(
              icon,
              width: iconSize.width,
              height: iconSize.height,
            ),
          ),
          SizedBox(width: 12.dsp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono(10, height: 14),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono(
                    11,
                    height: 16,
                    color: AppPalette.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

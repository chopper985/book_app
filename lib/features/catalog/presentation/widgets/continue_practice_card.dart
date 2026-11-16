// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_badge.dart';
import 'package:AppName/core/utils/widgets/app_progress_bar.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_style.dart';

/// Hero panel "Continue practice" (Technical Slate Panel).
class ContinuePracticeCard extends StatelessWidget {
  final ContinueSession session;
  final String title;
  final String subtitle;
  final int totalQuestions;
  final VoidCallback onContinue;

  const ContinuePracticeCard({
    super.key,
    required this.session,
    required this.title,
    required this.subtitle,
    required this.totalQuestions,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final ratio =
        totalQuestions == 0 ? 0.0 : session.answeredCount / totalQuestions;
    final style = TrackStyle.of(session.trackId);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.dsp),
      child: Container(
        decoration: const BoxDecoration(
          color: AppPalette.surfaceContainer,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              spreadRadius: -1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -32.dsp,
              bottom: -32.dsp,
              child: Container(
                width: 144.dsp,
                height: 144.dsp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primaryStrong.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.dsp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppBadge(
                        label: Strings.inProgress.i18n,
                        uppercase: true,
                        background: AppPalette.primaryContainer,
                        foreground: AppPalette.primary,
                        fontSize: 11,
                        lineHeight: 16,
                        radius: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                      ),
                      SizedBox(width: 8.dsp),
                      const AppSvg(
                        'assets/figma/explore/ic_clock.svg',
                        width: 10,
                        height: 10,
                      ),
                      SizedBox(width: 4.dsp),
                      Expanded(
                        child: Text(
                          Strings.minutesAgo.i18n.fill([session.minutesAgo]),
                          style: AppText.mono(10, height: 14),
                        ),
                      ),
                      Text(
                        '${(ratio * 100).round()}%',
                        style: AppText.mono(
                          11,
                          height: 16,
                          color: AppPalette.teal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.dsp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppText.sans(
                                16,
                                height: 24,
                                weight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.dsp),
                            Text(
                              subtitle,
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
                      Container(
                        width: 44.dsp,
                        height: 44.dsp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppPalette.surfaceHighest,
                          borderRadius: BorderRadius.circular(8.dsp),
                        ),
                        child: AppSvg(
                          style.icon,
                          width: style.iconSize.width,
                          height: style.iconSize.height,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.dsp),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Strings.sessionProgress.i18n,
                          style: AppText.mono(10, height: 14),
                        ),
                      ),
                      Text(
                        Strings.answeredOfTotal.i18n
                            .fill([session.answeredCount, totalQuestions]),
                        style: AppText.mono(
                          11,
                          height: 16,
                          weight: FontWeight.w400,
                          color: AppPalette.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.dsp),
                  AppProgressBar(
                    value: ratio,
                    height: 8,
                    inset: 2,
                    trackColor: AppPalette.surfaceHighest,
                    gradient: AppPalette.progressGradient,
                  ),
                  SizedBox(height: 16.dsp),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: AppPalette.primaryStrong,
                      borderRadius: BorderRadius.circular(8.dsp),
                      child: InkWell(
                        onTap: onContinue,
                        borderRadius: BorderRadius.circular(8.dsp),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 48.dsp),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AppSvg(
                                'assets/figma/explore/ic_play.svg',
                                width: 9.17,
                                height: 11.67,
                              ),
                              SizedBox(width: 8.dsp),
                              Text(
                                Strings.continuePractice.i18n,
                                style: AppText.sans(
                                  16,
                                  height: 24,
                                  weight: FontWeight.w600,
                                  color: AppPalette.onPrimaryStrong,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

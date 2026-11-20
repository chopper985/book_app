// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_badge.dart';
import 'package:interview_practice/core/utils/widgets/app_progress_bar.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_style.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_logo.dart';

/// Track card of the Explore list ("Article - 1. Flutter" in Figma).
class RoadmapCard extends StatelessWidget {
  final TrackOverview overview;

  /// Completed ratio 0..1 (mocked until progress is stored).
  final double completion;
  final VoidCallback onTap;

  const RoadmapCard({
    super.key,
    required this.overview,
    required this.completion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final track = overview.track;
    final style = TrackStyle.of(track.id);
    final total = overview.questionCount;
    final done = (completion * total).round();
    final tagline = track.tagline?.text ?? '';

    return Material(
      color: AppPalette.surfaceLow,
      borderRadius: BorderRadius.circular(8.dsp),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.dsp),
        child: Opacity(
          opacity: track.isAvailable ? 1 : 0.6,
          child: Padding(
            padding: EdgeInsets.all(16.dsp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40.dsp,
                      height: 40.dsp,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppPalette.surfaceHigh,
                        borderRadius: BorderRadius.circular(8.dsp),
                      ),
                      child: TrackLogo(trackId: track.id),
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
                                track.name.text,
                                style: AppText.sans(
                                  16,
                                  height: 24,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              if (track.badge != null)
                                AppBadge(
                                  label: track.badge!.text,
                                  background: style.badgeBackground,
                                  foreground: style.badgeForeground,
                                ),
                            ],
                          ),
                          SizedBox(height: 2.dsp),
                          Text(
                            track.isAvailable
                                ? Strings.trackQuestionsTagline.i18n
                                    .fill([total, tagline])
                                : tagline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    Text(
                      track.isAvailable ? '${(completion * 100).round()}%' : '',
                      style: AppText.mono(
                        11,
                        height: 16,
                        color: style.percentColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.dsp),
                Row(
                  children: [
                    TrackLogo(trackId: track.id, meta: true),
                    SizedBox(width: 4.dsp),
                    Expanded(
                      child: Text(
                        track.audience?.text ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.mono(10, height: 14),
                      ),
                    ),
                    Text(
                      track.isAvailable
                          ? Strings.completedOfTotal.i18n.fill([done, total])
                          : Strings.comingSoon.i18n,
                      style: AppText.mono(
                        11,
                        height: 16,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.dsp),
                AppProgressBar(
                  value: track.isAvailable ? completion : 0,
                  color: style.barColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

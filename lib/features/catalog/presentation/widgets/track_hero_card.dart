// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_badge.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_detail.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_progress.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/segmented_progress_bar.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/content/presentation/extensions/question_level_label.dart';
import 'package:interview_practice/gen/assets.gen.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_logo.dart';

/// "Technology Route Hero Card": title, badges and overall progress.
class TrackHeroCard extends StatelessWidget {
  final TrackDetail detail;
  final TrackProgress progress;
  final VoidCallback onToggleSaved;

  const TrackHeroCard({
    super.key,
    required this.detail,
    required this.progress,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    final track = detail.track;
    final badge = track.badge?.text;
    final version = detail.learning.versionLabel;
    final maxLevel = detail.maxLevel;
    // The roadmap's level range ("Fresher / Junior"), else the track's own
    // audience label.
    final audience = maxLevel == null
        ? track.audience?.text
        : [
            for (final level in QuestionLevel.values)
              if (level.index <= maxLevel.index) level.label,
          ].join(' / ');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.dsp),
      child: ColoredBox(
        color: AppPalette.surfaceContainer,
        child: Stack(
          children: [
            Positioned(
              right: -16.dsp,
              top: -32.dsp,
              child: Container(
                width: 144.dsp,
                height: 144.dsp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primaryStrong.withValues(alpha: 0.08),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 15.dsp),
                        child: Container(
                          width: 45.dsp,
                          height: 48.dsp,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppPalette.surfaceHighest,
                            borderRadius: BorderRadius.circular(8.dsp),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TrackLogo(trackId: track.id, scale: 1.25),
                        ),
                      ),
                      SizedBox(width: 8.dsp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (badge != null || version != null)
                              Padding(
                                padding: EdgeInsets.only(bottom: 4.dsp),
                                child: Wrap(
                                  spacing: 6.dsp,
                                  runSpacing: 4.dsp,
                                  children: [
                                    if (badge != null)
                                      AppBadge(
                                        label: badge,
                                        uppercase: true,
                                        background: AppPalette.tealContainer,
                                        foreground: AppPalette.teal,
                                        radius: 4,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                      ),
                                    if (version != null)
                                      AppBadge(
                                        label: version,
                                        background: AppPalette.surfaceHighest,
                                        foreground: AppPalette.onSurfaceVariant,
                                        radius: 4,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            Text(
                              Strings.trackHeroTitle.i18n
                                  .fill([track.name.text]),
                              style: AppText.sans(
                                20,
                                height: 28,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.dsp),
                      _SaveButton(
                        isSaved: detail.learning.isSaved,
                        onTap: onToggleSaved,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.dsp),
                  _Pill(
                    background: AppPalette.teal.withValues(alpha: 0.1),
                    leading: AppSvg(
                      Assets.figma.result.feedbackBadge,
                      width: 12.83,
                      height: 12.25,
                      color: AppPalette.teal,
                    ),
                    label: Strings.trackTotalQuestions.i18n
                        .fill([detail.questionCount]),
                    color: AppPalette.teal,
                  ),
                  if (audience != null) ...[
                    SizedBox(height: 8.dsp),
                    _Pill(
                      background: AppPalette.surfaceLowest,
                      label: Strings.trackAudienceLevel.i18n.fill([audience]),
                      color: AppPalette.onSurface,
                    ),
                  ],
                  SizedBox(height: 16.dsp),
                  _OverallProgress(progress: progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onTap;

  const _SaveButton({required this.isSaved, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isSaved ? Strings.trackUnsave.i18n : Strings.trackSave.i18n,
      child: Material(
        color: AppPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(6.dsp),
        child: InkWell(
          borderRadius: BorderRadius.circular(6.dsp),
          onTap: onTap,
          child: SizedBox(
            width: 34.dsp,
            height: 36.dsp,
            child: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 16.dsp,
              color: isSaved ? AppPalette.primary : AppPalette.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Color background;
  final Widget? leading;
  final String label;
  final Color color;

  const _Pill({
    required this.background,
    required this.label,
    required this.color,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.dsp, vertical: 4.dsp),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.dsp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: 4.dsp)],
          Flexible(
            child: Text(
              label,
              style: AppText.mono(
                11,
                height: 16,
                weight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Overall Track Progress Dashboard".
class _OverallProgress extends StatelessWidget {
  final TrackProgress progress;

  const _OverallProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLow,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.data_usage,
                size: 13.3.dsp,
                color: AppPalette.primary,
              ),
              SizedBox(width: 6.dsp),
              Expanded(
                child: Text(
                  Strings.trackOverallProgress.i18n,
                  style: AppText.sans(12, height: 18),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${progress.percent}%',
                      style: AppText.mono(
                        13,
                        height: 20,
                        weight: FontWeight.w700,
                        color: AppPalette.primary,
                      ),
                    ),
                    TextSpan(
                      text: Strings.trackAnsweredOfTotal.i18n
                          .fill([progress.answered, progress.total]),
                      style: AppText.mono(
                        11,
                        height: 16,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.dsp),
          SegmentedProgressBar(
            height: 8,
            segments: [
              ProgressSegment(progress.correctRatio, AppPalette.primaryStrong),
              ProgressSegment(progress.wrongRatio, AppPalette.error),
            ],
          ),
          SizedBox(height: 8.dsp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 14.dsp,
                  runSpacing: 4.dsp,
                  children: [
                    _Legend(
                      color: AppPalette.primaryStrong,
                      label: Strings.trackLegendCorrect.i18n,
                      value: progress.correct,
                    ),
                    _Legend(
                      color: AppPalette.error,
                      label: Strings.trackLegendReview.i18n,
                      value: progress.wrong,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.dsp),
              Text(
                Strings.trackLegendRemaining.i18n.fill([progress.remaining]),
                style: AppText.mono(10, height: 14, weight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.dsp,
          height: 8.dsp,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.dsp),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: label),
              TextSpan(
                text: '$value',
                style: AppText.mono(
                  10,
                  height: 14,
                  weight: FontWeight.w700,
                  color: AppPalette.onSurface,
                ),
              ),
            ],
          ),
          style: AppText.mono(10, height: 14, weight: FontWeight.w400),
        ),
      ],
    );
  }
}

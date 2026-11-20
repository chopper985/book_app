// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_progress.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/segmented_progress_bar.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Header of the "Core Topic Modules" section.
class TopicSectionHeader extends StatelessWidget {
  final int topicCount;

  const TopicSectionHeader({super.key, required this.topicCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10.dsp,
          height: 10.dsp,
          decoration: BoxDecoration(
            color: AppPalette.primaryStrong,
            borderRadius: BorderRadius.circular(2.dsp),
          ),
        ),
        SizedBox(width: 8.dsp),
        Expanded(
          child: Text(
            Strings.trackTopicsHeader.i18n.fill([topicCount]),
            style: AppText.sans(16, height: 24, weight: FontWeight.w600),
          ),
        ),
        SizedBox(width: 8.dsp),
        Text(
          Strings.trackTopicsHint.i18n.toUpperCase(),
          style: AppText.mono(
            10,
            height: 14,
            weight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

/// One topic module: status, progress, stats and a practice button.
class TopicModuleCard extends StatelessWidget {
  final int index;
  final TopicProgress progress;

  /// `null` when no set contains the topic yet.
  final VoidCallback? onPractice;

  const TopicModuleCard({
    super.key,
    required this.index,
    required this.progress,
    this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    final look = _StatusLook.of(progress.status);
    final description = progress.topic.description?.text;
    final needsReview = progress.status == TopicStatus.needsReview;

    return Container(
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.dsp,
                height: 32.dsp,
                margin: EdgeInsets.only(top: 2.dsp),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppPalette.surfaceHigh,
                  borderRadius: BorderRadius.circular(6.dsp),
                ),
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: AppText.mono(
                    13,
                    height: 20,
                    weight: FontWeight.w700,
                    color: look.indexColor,
                  ),
                ),
              ),
              SizedBox(width: 10.dsp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progress.topic.name.text,
                      style: AppText.sans(
                        16,
                        height: 20,
                        weight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.dsp),
                    Row(
                      children: [
                        Icon(look.icon, size: 11.dsp, color: look.color),
                        SizedBox(width: 4.dsp),
                        Flexible(
                          child: Text(
                            look.label,
                            style: AppText.mono(
                              10,
                              height: 14,
                              weight: FontWeight.w500,
                              color: look.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.dsp),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${progress.answered}/${progress.total}',
                      style: AppText.mono(
                        14,
                        height: 20,
                        weight: FontWeight.w700,
                        color: look.scoreColor,
                      ),
                    ),
                    TextSpan(
                      text: ' (${progress.percent}%)',
                      style: AppText.mono(
                        10,
                        height: 14,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description != null) ...[
            SizedBox(height: 12.dsp),
            Text(
              description,
              style: AppText.sans(
                13,
                height: 19.5,
                color: AppPalette.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 16.dsp),
          SegmentedProgressBar(
            segments: needsReview
                ? [
                    ProgressSegment(progress.correctRatio, AppPalette.teal),
                    ProgressSegment(progress.wrongRatio, AppPalette.error),
                  ]
                : [ProgressSegment(progress.ratio, look.barColor)],
          ),
          SizedBox(height: 6.dsp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  Strings.trackTopicCorrectWrong.i18n
                          .fill([progress.correct, progress.wrong]) +
                      (needsReview ? Strings.trackTopicReviewNow.i18n : ''),
                  style: AppText.mono(
                    10,
                    height: 14,
                    weight: FontWeight.w500,
                    color: look.statsColor,
                  ),
                ),
              ),
              SizedBox(width: 8.dsp),
              Text(
                (needsReview
                        ? Strings.trackTopicLeft
                        : Strings.trackTopicNewLeft)
                    .i18n
                    .fill([progress.remaining]),
                style: AppText.mono(
                  10,
                  height: 14,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.dsp),
          _Footer(progress: progress, look: look, onPractice: onPractice),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final TopicProgress progress;
  final _StatusLook look;
  final VoidCallback? onPractice;

  const _Footer({
    required this.progress,
    required this.look,
    required this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    final (Widget icon, String hint, Color hintColor) = switch (progress) {
      TopicProgress(status: TopicStatus.needsReview, :final wrong) => (
          AppSvg(
            Assets.figma.result.review,
            width: 12.57,
            height: 9.14,
            color: AppPalette.error,
          ),
          Strings.trackTopicMistakes.i18n.fill([wrong]),
          AppPalette.error,
        ),
      TopicProgress(:final int estimatedMinutes) => (
          AppSvg(
            Assets.figma.explore.icClock,
            width: 11.67,
            height: 11.67,
            color: AppPalette.onSurfaceVariant,
          ),
          Strings.trackTopicEstimate.i18n.fill([estimatedMinutes]),
          AppPalette.onSurfaceVariant,
        ),
      _ => (
          Icon(
            Icons.speed,
            size: 12.dsp,
            color: AppPalette.onSurfaceVariant,
          ),
          Strings.trackTopicDeepDive.i18n,
          AppPalette.onSurfaceVariant,
        ),
    };
    final filled = progress.status == TopicStatus.learning;
    final radius = BorderRadius.circular(6.dsp);

    return Container(
      padding: EdgeInsets.all(8.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLow,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Row(
        children: [
          SizedBox(width: 4.dsp),
          icon,
          SizedBox(width: 6.dsp),
          Expanded(
            child: Text(
              hint,
              style: AppText.mono(
                10,
                height: 14,
                weight: FontWeight.w500,
                color: hintColor,
              ),
            ),
          ),
          SizedBox(width: 8.dsp),
          Material(
            color: filled ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
            borderRadius: radius,
            child: InkWell(
              onTap: onPractice,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 28.dsp),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.dsp,
                    vertical: 6.dsp,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filled
                            ? Strings.trackTopicContinue.i18n
                            : Strings.trackTopicReview.i18n,
                        style: AppText.mono(
                          12,
                          height: 16,
                          weight: FontWeight.w700,
                          color: onPractice == null
                              ? AppPalette.onSurfaceVariant
                              : filled
                                  ? AppPalette.onPrimaryStrong
                                  : AppPalette.primary,
                        ),
                      ),
                      SizedBox(width: 4.dsp),
                      AppSvg(
                        Assets.figma.explore.icChevronRight,
                        width: 4.32,
                        height: 7,
                        color: filled
                            ? AppPalette.onPrimaryStrong
                            : AppPalette.primary,
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

class _StatusLook {
  final IconData icon;
  final String label;
  final Color color;
  final Color indexColor;
  final Color scoreColor;
  final Color barColor;
  final Color statsColor;

  const _StatusLook({
    required this.icon,
    required this.label,
    required this.color,
    required this.indexColor,
    required this.scoreColor,
    required this.barColor,
    required this.statsColor,
  });

  static _StatusLook of(TopicStatus status) => switch (status) {
        TopicStatus.almostDone => _StatusLook(
            icon: Icons.auto_awesome,
            label: Strings.trackStatusAlmostDone.i18n,
            color: AppPalette.teal,
            indexColor: AppPalette.primary,
            scoreColor: AppPalette.teal,
            barColor: AppPalette.teal,
            statsColor: AppPalette.teal,
          ),
        TopicStatus.learning => _StatusLook(
            icon: Icons.sync,
            label: Strings.trackStatusLearning.i18n,
            color: AppPalette.primary,
            indexColor: AppPalette.primary,
            scoreColor: AppPalette.primary,
            barColor: AppPalette.primaryStrong,
            statsColor: AppPalette.primary,
          ),
        TopicStatus.needsReview => _StatusLook(
            icon: Icons.priority_high,
            label: Strings.trackStatusNeedsReview.i18n,
            color: AppPalette.error,
            indexColor: AppPalette.purple,
            scoreColor: AppPalette.onSurface,
            barColor: AppPalette.teal,
            statsColor: AppPalette.error,
          ),
        TopicStatus.lowPractice => _StatusLook(
            icon: Icons.hourglass_empty,
            label: Strings.trackStatusLowPractice.i18n,
            color: AppPalette.onSurfaceVariant,
            indexColor: AppPalette.onSurfaceVariant,
            scoreColor: AppPalette.onSurface,
            barColor: AppPalette.primary,
            statsColor: AppPalette.primary,
          ),
      };
}

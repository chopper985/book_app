// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_inline_text.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_score_ring.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// MOCK: there is no XP system yet, the reward card shows a fixed value.
const int kResultMockRewardXp = 45;

/// Section 1: radial chart, qualitative feedback and 3 summary cards.
class ResultOverviewCard extends StatelessWidget {
  final ResultBundle bundle;

  const ResultOverviewCard({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final result = bundle.result;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.dsp),
      child: Container(
        decoration: const BoxDecoration(
          color: AppPalette.surfaceContainer,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -32.dsp,
              top: -32.dsp,
              child: Container(
                width: 128.dsp,
                height: 128.dsp,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primary.withValues(alpha: 0.05),
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
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.dsp),
                    child: ResultScoreRing(
                      correct: result.correctCount,
                      graded: result.gradedCount,
                      ratio: result.scoreRatio,
                      percent: result.scorePercent,
                    ),
                  ),
                  SizedBox(height: 4.dsp),
                  _Feedback(bundle: bundle),
                  SizedBox(height: 16.dsp),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          icon: Assets.figma.result.timer,
                          iconWidth: 13.5,
                          iconHeight: 15.75,
                          label: Strings.resultTime.i18n,
                          value: _formatDuration(result.duration),
                        ),
                      ),
                      SizedBox(width: 4.dsp),
                      Expanded(
                        child: _SummaryCard(
                          icon: Assets.figma.result.score,
                          iconWidth: 15,
                          iconHeight: 15,
                          label: Strings.resultScore.i18n,
                          value: Strings.resultScoreValue.i18n
                              .fill([result.scorePercent]),
                        ),
                      ),
                      SizedBox(width: 4.dsp),
                      Expanded(
                        child: _SummaryCard(
                          icon: Assets.figma.result.reward,
                          iconWidth: 12,
                          iconHeight: 14.25,
                          label: Strings.resultReward.i18n,
                          value: Strings.resultRewardValue.i18n
                              .fill([kResultMockRewardXp]),
                          valueColor: AppPalette.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final d = duration.isNegative ? Duration.zero : duration;
    String two(int v) => v.toString().padLeft(2, '0');
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes >= 60) {
      return '${d.inHours}:${two(minutes % 60)}:${two(seconds)}';
    }
    return '${two(minutes)}:${two(seconds)}';
  }
}

class _Feedback extends StatelessWidget {
  final ResultBundle bundle;

  const _Feedback({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final percent = bundle.result.scorePercent;
    final (label, template, color) = percent >= 80
        ? (
            Strings.resultBandGreat,
            Strings.resultFeedbackGreat,
            AppPalette.teal
          )
        : percent >= 50
            ? (
                Strings.resultBandGood,
                Strings.resultFeedbackGood,
                AppPalette.teal
              )
            : (
                Strings.resultBandWeak,
                Strings.resultFeedbackWeak,
                AppPalette.error
              );
    final (strong, weak) = _topics();
    // (topic name, is weak topic)
    final values = percent >= 80
        ? [(strong, false)]
        : percent >= 50
            ? [(strong, false), (weak, true)]
            : [(weak, true)];
    final base =
        AppText.sans(14, height: 20, color: AppPalette.onSurfaceVariant);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 320.dsp),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.dsp, vertical: 2.dsp),
            decoration: BoxDecoration(
              color: color == AppPalette.teal
                  ? AppPalette.tealContainer
                  : AppPalette.errorContainer,
              borderRadius: BorderRadius.circular(12.dsp),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSvg(
                  Assets.figma.result.feedbackBadge,
                  width: 12.83,
                  height: 12.25,
                  color: color,
                ),
                SizedBox(width: 6.dsp),
                Flexible(
                  child: Text(
                    label.i18n,
                    style: AppText.mono(12, height: 16, color: color),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.dsp),
          Text.rich(
            TextSpan(
              children: resultTemplateSpans(
                template.i18n,
                base: base,
                values: [
                  for (final (name, isWeak) in values)
                    (
                      name,
                      AppText.sans(
                        14,
                        height: 20,
                        weight: FontWeight.w500,
                        color: isWeak ? AppPalette.error : AppPalette.onSurface,
                      ),
                    ),
                ],
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Topic with the most correct answers and topic with the most mistakes,
  /// falling back to the track name.
  (String, String) _topics() {
    final correct = <String, int>{};
    final wrong = <String, int>{};
    for (final item in bundle.result.items) {
      final topicId = bundle.questions[item.questionId]?.topicId;
      if (topicId == null || !item.status.isGraded) continue;
      final target = item.status == AnswerStatus.correct ? correct : wrong;
      target[topicId] = (target[topicId] ?? 0) + 1;
    }
    String name(Map<String, int> counts) {
      if (counts.isEmpty) return bundle.track.name.text;
      final top = counts.entries.reduce((a, b) => b.value > a.value ? b : a);
      return bundle.track.topicById(top.key)?.name.text ??
          bundle.track.name.text;
    }

    return (name(correct), name(wrong));
  }
}

class _SummaryCard extends StatelessWidget {
  final String icon;
  final double iconWidth;
  final double iconHeight;
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryCard({
    required this.icon,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
    required this.value,
    this.valueColor = AppPalette.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Column(
        children: [
          AppSvg(icon, width: iconWidth, height: iconHeight),
          SizedBox(height: 2.dsp),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.mono(10, height: 14),
          ),
          SizedBox(height: 2.dsp),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppText.mono(13, height: 20, color: valueColor),
          ),
        ],
      ),
    );
  }
}

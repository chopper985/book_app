// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_code_view.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_inline_text.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Wrong or skipped question: answer comparison, code and explanation.
class ResultMistakeCard extends StatelessWidget {
  final Question question;
  final QuestionResult item;
  final int number;
  final String topicLine;

  const ResultMistakeCard({
    super.key,
    required this.question,
    required this.item,
    required this.number,
    required this.topicLine,
  });

  @override
  Widget build(BuildContext context) {
    final skipped = item.status == AnswerStatus.skipped;
    final selected = _option(item.selectedOptionId);
    final correct = _option(item.correctOptionId ?? question.answerId);

    return _ReviewCardFrame(
      children: [
        _QuestionHeader(
          topicLine: topicLine,
          badge: skipped
              ? Strings.resultSkippedBadge.i18n
              : Strings.resultQuestionNumber.i18n.fill([number]),
          badgeIcon: !skipped,
          prompt: question.prompt.text,
        ),
        _AnswerBox(
          label: Strings.resultYourAnswer.i18n,
          icon: Assets.figma.result.wrongCircle,
          option: selected == null ? null : _letter(selected),
          text: selected?.text.text ?? Strings.resultSkippedAnswer.i18n,
          background: AppPalette.errorStrong.withValues(alpha: 0.2),
          labelBackground: AppPalette.error.withValues(alpha: 0.25),
          color: AppPalette.error,
        ),
        if (correct != null)
          _AnswerBox(
            label: Strings.resultCorrectAnswer.i18n,
            icon: Assets.figma.result.checkCircle,
            option: _letter(correct),
            text: correct.text.text,
            background: const Color(0x2603C6B2),
            labelBackground: AppPalette.teal.withValues(alpha: 0.25),
            color: AppPalette.teal,
          ),
        if (question.code != null) ResultCodeView(code: question.code!),
        ResultExplanationBox(text: question.explanation.text),
      ],
    );
  }

  QuestionOption? _option(String? id) {
    for (final option in question.options) {
      if (option.id == id) return option;
    }
    return null;
  }

  String _letter(QuestionOption option) {
    final index = question.options.indexOf(option);
    return Strings.resultOptionLetter.i18n
        .fill([String.fromCharCode(0x41 + index)]);
  }
}

/// Self-explain question: key-point checklist (not scored) and explanation.
class ResultSelfCheckCard extends StatelessWidget {
  final Question question;
  final int number;
  final String topicLine;
  final Set<int> checked;
  final ValueChanged<int> onToggle;

  const ResultSelfCheckCard({
    super.key,
    required this.question,
    required this.number,
    required this.topicLine,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final points = question.keyPoints;
    return _ReviewCardFrame(
      children: [
        _QuestionHeader(
          topicLine: topicLine,
          badge: Strings.resultQuestionNumber.i18n.fill([number]),
          badgeIcon: false,
          badgeColor: AppPalette.purple,
          prompt: question.prompt.text,
        ),
        if (question.code != null) ResultCodeView(code: question.code!),
        if (points.isNotEmpty)
          Container(
            padding: EdgeInsets.all(8.dsp),
            decoration: BoxDecoration(
              color: AppPalette.purpleContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.dsp),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Strings.resultKeyPointsProgress.i18n.fill([
                    checked.where((i) => i < points.length).length,
                    points.length,
                  ]),
                  style: AppText.mono(10, height: 14, color: AppPalette.purple),
                ),
                SizedBox(height: 4.dsp),
                for (var i = 0; i < points.length; i++)
                  _KeyPointRow(
                    text: points[i].text,
                    checked: checked.contains(i),
                    onTap: () => onToggle(i),
                  ),
              ],
            ),
          ),
        ResultExplanationBox(text: question.explanation.text),
      ],
    );
  }
}

/// Deep Interview Explanation Box.
class ResultExplanationBox extends StatelessWidget {
  final String text;

  const ResultExplanationBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
              AppSvg(
                Assets.figma.result.insight,
                width: 12.67,
                height: 13.33,
              ),
              SizedBox(width: 6.dsp),
              Expanded(
                child: Text(
                  Strings.resultInsightTitle.i18n,
                  style: AppText.mono(
                    12,
                    height: 16,
                    color: AppPalette.primary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.dsp),
          Text.rich(
            TextSpan(
              children: resultInlineSpans(
                text,
                base: AppText.sans(
                  12,
                  height: 19.5,
                  color: AppPalette.onSurfaceVariant,
                ),
                code: AppText.mono(
                  11,
                  height: 16,
                  weight: FontWeight.w500,
                  color: AppPalette.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCardFrame extends StatelessWidget {
  final List<Widget> children;

  const _ReviewCardFrame({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(8.dsp),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: i == 1 ? 16.dsp : 8.dsp),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  final String topicLine;
  final String badge;
  final bool badgeIcon;
  final Color badgeColor;
  final String prompt;

  const _QuestionHeader({
    required this.topicLine,
    required this.badge,
    required this.badgeIcon,
    required this.prompt,
    this.badgeColor = AppPalette.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                topicLine.toUpperCase(),
                style: AppText.mono(
                  10,
                  height: 14,
                  color: AppPalette.primary,
                  letterSpacing: 0.25,
                ),
              ),
            ),
            SizedBox(width: 8.dsp),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.dsp, vertical: 2.dsp),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.dsp),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeIcon) ...[
                    AppSvg(
                      Assets.figma.result.closeSmall,
                      width: 7,
                      height: 7,
                      color: badgeColor,
                    ),
                    SizedBox(width: 4.dsp),
                  ],
                  Text(
                    badge,
                    style: AppText.mono(10, height: 14, color: badgeColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.dsp),
        Text.rich(
          TextSpan(
            children: resultInlineSpans(
              prompt,
              base: AppText.sans(16, height: 24, weight: FontWeight.w600),
              code: AppText.mono(
                15,
                height: 24,
                color: AppPalette.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerBox extends StatelessWidget {
  final String label;
  final String icon;
  final String? option;
  final String text;
  final Color background;
  final Color labelBackground;
  final Color color;

  const _AnswerBox({
    required this.label,
    required this.icon,
    required this.option,
    required this.text,
    required this.background,
    required this.labelBackground,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.dsp),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.dsp,
                    vertical: 2.dsp,
                  ),
                  decoration: BoxDecoration(
                    color: labelBackground,
                    borderRadius: BorderRadius.circular(2.dsp),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvg(icon, width: 10, height: 10, color: color),
                      SizedBox(width: 4.dsp),
                      Flexible(
                        child: Text(
                          label,
                          style: AppText.mono(10, height: 14, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (option != null) ...[
                const Spacer(),
                Text(
                  option!,
                  style: AppText.mono(
                    11,
                    height: 16,
                    weight: FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 6.dsp),
          Text.rich(
            TextSpan(
              children: resultInlineSpans(
                text,
                base: AppText.sans(14, height: 20, color: color),
                code: AppText.mono(
                  13,
                  height: 20,
                  weight: FontWeight.w500,
                  color: AppPalette.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyPointRow extends StatelessWidget {
  final String text;
  final bool checked;
  final VoidCallback onTap;

  const _KeyPointRow({
    required this.text,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.dsp),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.dsp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18.dsp,
                height: 18.dsp,
                margin: EdgeInsets.only(top: 1.dsp),
                decoration: BoxDecoration(
                  color: checked ? AppPalette.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.dsp),
                  border: Border.all(
                    color:
                        checked ? AppPalette.teal : AppPalette.onSurfaceVariant,
                    width: 1.5,
                  ),
                ),
                child: checked
                    ? Icon(
                        Icons.check,
                        size: 14.dsp,
                        color: AppPalette.surface,
                      )
                    : null,
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: resultInlineSpans(
                      text,
                      base: AppText.sans(
                        14,
                        height: 20,
                        color: checked
                            ? AppPalette.onSurface
                            : AppPalette.onSurfaceVariant,
                      ),
                      code: AppText.mono(
                        13,
                        height: 20,
                        weight: FontWeight.w500,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

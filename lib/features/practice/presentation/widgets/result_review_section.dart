// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_review_card.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Section 3: wrong/skipped questions, then self-explain self-checks.
class ResultReviewSection extends StatelessWidget {
  final ResultBundle bundle;
  final Map<String, Set<int>> checkedPoints;
  final void Function(String questionId, int index) onToggleKeyPoint;

  const ResultReviewSection({
    super.key,
    required this.bundle,
    required this.checkedPoints,
    required this.onToggleKeyPoint,
  });

  @override
  Widget build(BuildContext context) {
    final result = bundle.result;
    final items = result.items;
    final gap = SizedBox(height: 16.dsp);

    final mistakes = <Widget>[];
    final selfChecks = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final question = bundle.questions[item.questionId];
      if (question == null) continue;
      switch (item.status) {
        case AnswerStatus.incorrect || AnswerStatus.skipped:
          mistakes.add(
            ResultMistakeCard(
              question: question,
              item: item,
              number: i + 1,
              topicLine: _topicLine(question),
            ),
          );
        case AnswerStatus.selfCheck:
          selfChecks.add(
            ResultSelfCheckCard(
              question: question,
              number: i + 1,
              topicLine: _topicLine(question),
              checked: checkedPoints[question.id] ?? const {},
              onToggle: (index) => onToggleKeyPoint(question.id, index),
            ),
          );
        case AnswerStatus.correct:
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          icon: AppSvg(
            Assets.figma.result.analysis,
            width: 16.67,
            height: 15.83,
          ),
          title: Strings.resultReviewTitle.i18n,
          trailing: mistakes.isEmpty
              ? null
              : Strings.resultMistakeSummary.i18n
                  .fill([result.incorrectCount, result.skippedCount]),
        ),
        gap,
        if (mistakes.isEmpty)
          const _NoMistakes()
        else
          for (var i = 0; i < mistakes.length; i++) ...[
            if (i > 0) gap,
            mistakes[i],
          ],
        if (selfChecks.isNotEmpty) ...[
          SizedBox(height: 24.dsp),
          _SectionTitle(
            icon: Icon(
              Icons.checklist_rounded,
              size: 18.dsp,
              color: AppPalette.purple,
            ),
            title: Strings.resultSelfCheckTitle.i18n,
            trailing: Strings.resultSelfCheckNote.i18n,
          ),
          gap,
          for (var i = 0; i < selfChecks.length; i++) ...[
            if (i > 0) gap,
            selfChecks[i],
          ],
        ],
      ],
    );
  }

  String _topicLine(Question question) {
    final topic = bundle.track.topicById(question.topicId)?.name.text;
    final track = bundle.track.name.text;
    return topic == null ? track : '$track • $topic';
  }
}

class _SectionTitle extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? trailing;

  const _SectionTitle({required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(width: 8.dsp),
        Expanded(
          child: Text(
            title,
            style: AppText.sans(16, height: 24, weight: FontWeight.w600),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8.dsp),
          Flexible(
            child: Text(
              trailing!,
              textAlign: TextAlign.end,
              style: AppText.mono(10, height: 14),
            ),
          ),
        ],
      ],
    );
  }
}

class _NoMistakes extends StatelessWidget {
  const _NoMistakes();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.tealContainer,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Column(
        children: [
          AppSvg(
            Assets.figma.result.feedbackBadge,
            width: 25.67,
            height: 24.5,
            color: AppPalette.teal,
          ),
          SizedBox(height: 8.dsp),
          Text(
            Strings.resultNoMistakesTitle.i18n,
            textAlign: TextAlign.center,
            style: AppText.sans(
              16,
              height: 24,
              weight: FontWeight.w600,
              color: AppPalette.teal,
            ),
          ),
          SizedBox(height: 4.dsp),
          Text(
            Strings.resultNoMistakesBody.i18n,
            textAlign: TextAlign.center,
            style: AppText.sans(
              14,
              height: 20,
              color: AppPalette.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

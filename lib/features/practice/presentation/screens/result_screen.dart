// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/presentation/extensions/question_level_label.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/presentation/cubit/result_cubit.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_actions.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_header.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_overview_card.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_review_section.dart';

/// "Kết quả bài luyện - Chi tiết câu sai".
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.surface,
      body: BlocBuilder<ResultCubit, ResultState>(
        builder: (context, state) {
          final loaded = state is ResultLoaded ? state : null;
          return Column(
            children: [
              ResultHeader(
                onBack: () => _back(context),
                levelLabel: loaded == null ? null : _levelLabel(loaded.bundle),
                progress: loaded?.bundle.result.scoreRatio,
              ),
              Expanded(
                child: switch (state) {
                  ResultLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  ResultNotFound() => Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.dsp),
                        child: Text(
                          Strings.resultNotFound.i18n,
                          textAlign: TextAlign.center,
                          style: AppText.sans(
                            14,
                            height: 20,
                            color: AppPalette.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ResultLoaded() => _Body(state: state),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      const RootRoute().go(context);
    }
  }

  /// The hardest level of the set.
  static String _levelLabel(ResultBundle bundle) {
    var level = QuestionLevel.fresher;
    for (final question in bundle.questions.values) {
      if (question.level.index > level.index) level = question.level;
    }
    return level.label;
  }
}

class _Body extends StatelessWidget {
  final ResultLoaded state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final bundle = state.bundle;
    final result = bundle.result;
    final mistakes = result.mistakes;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.dsp, 16.dsp, 16.dsp, 32.dsp),
      children: [
        ResultOverviewCard(bundle: bundle),
        SizedBox(height: 24.dsp),
        ResultActions(
          mistakeCount: mistakes.length,
          onReviewMistakes: () => PracticeRoute(
            setId: bundle.set.id,
            only: mistakes.map((m) => m.questionId).join(','),
          ).pushReplacement(context),
          onExplore: () => const RootRoute().go(context),
          onRetrySet: () =>
              PracticeRoute(setId: bundle.set.id).pushReplacement(context),
        ),
        SizedBox(height: 24.dsp),
        ResultReviewSection(
          bundle: bundle,
          checkedPoints: state.checkedPoints,
          onToggleKeyPoint: context.read<ResultCubit>().toggleKeyPoint,
        ),
      ],
    );
  }
}

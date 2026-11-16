// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/navigator/app_router.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/practice/domain/entities/practice_bundle.dart';
import 'package:AppName/features/practice/presentation/cubit/result_cubit.dart';
import 'package:AppName/features/practice/presentation/widgets/result_actions.dart';
import 'package:AppName/features/practice/presentation/widgets/result_header.dart';
import 'package:AppName/features/practice/presentation/widgets/result_overview_card.dart';
import 'package:AppName/features/practice/presentation/widgets/result_review_section.dart';

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

  static String _levelLabel(ResultBundle bundle) {
    final junior = bundle.questions.values
        .any((question) => question.level == QuestionLevel.junior);
    return (junior ? Strings.levelJunior : Strings.levelFresher).i18n;
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

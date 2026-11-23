// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/learner_tab_header.dart';
import 'package:interview_practice/features/content/presentation/widgets/content_issue_view.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_hub_cubit.dart';
import 'package:interview_practice/features/practice/presentation/widgets/hub_sections.dart';

/// Practice tab: mistakes to review, quick practice and history.
class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PracticeHubCubit, PracticeHubState>(
        builder: (context, state) => switch (state) {
          PracticeHubLoading() => const Center(
              child: CircularProgressIndicator(color: AppPalette.primary),
            ),
          PracticeHubInvalidContent(:final issues) => SafeArea(
              child: ContentIssueView(
                issues: issues,
                onRetry: context.read<PracticeHubCubit>().load,
              ),
            ),
          PracticeHubLoaded() => _Body(state: state),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PracticeHubLoaded state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final hub = state.hub;
    return Column(
      children: [
        LearnerTabHeader(
          learner: state.learner,
          title: Strings.hubTitle.i18n,
          subtitle: hub.mistakeCount > 0
              ? Strings.hubMistakeCount.i18n.fill([hub.mistakeCount])
              : Strings.hubSessionCount.i18n.fill([hub.sessionCount]),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.dsp, 16.dsp, 16.dsp, 24.dsp),
            children: [
              HubStats(hub: hub),
              SizedBox(height: 24.dsp),
              HubSectionTitle(Strings.hubMistakesTitle.i18n),
              if (hub.mistakes.isEmpty)
                HubEmpty(Strings.hubMistakesEmpty.i18n)
              else
                for (final group in hub.mistakes)
                  MistakeRow(
                    group: group,
                    onTap: () => PracticeRoute(
                      setId: group.set.id,
                      only: group.questionIds.join(','),
                    ).push<void>(context),
                  ),
              if (hub.quickPractices.isNotEmpty) ...[
                SizedBox(height: 24.dsp),
                HubSectionTitle(Strings.hubQuickTitle.i18n),
                for (final practice in hub.quickPractices)
                  QuickPracticeRow(
                    practice: practice,
                    onTap: () => PracticeRoute(
                      setId: practice.set.id,
                      only: practice.pickQuestions()?.join(','),
                    ).push<void>(context),
                  ),
              ],
              SizedBox(height: 24.dsp),
              HubSectionTitle(Strings.hubHistoryTitle.i18n),
              if (hub.history.isEmpty)
                HubEmpty(Strings.hubHistoryEmpty.i18n)
              else
                for (final entry in hub.history)
                  HistoryRow(
                    entry: entry,
                    onTap: () => ResultRoute(sessionId: entry.result.sessionId)
                        .push<void>(context),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

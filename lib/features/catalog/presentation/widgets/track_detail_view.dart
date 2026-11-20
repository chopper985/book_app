// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/navigator/app_router.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_progress_bar.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/daily_snippet_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/topic_module_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_hero_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_quick_actions.dart';
import 'package:AppName/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:AppName/features/content/presentation/widgets/content_issue_view.dart';
import 'package:AppName/features/practice/presentation/helpers/practice_launcher.dart';

/// "Lộ trình Flutter - Chi tiết chủ đề" (Figma 310:866), driven by a
/// [TrackDetailCubit]. [top] sits above the hero card: the roadmap switcher
/// in the Roadmaps tab.
class TrackDetailView extends StatelessWidget {
  final Widget top;

  const TrackDetailView({super.key, required this.top});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackDetailCubit, TrackDetailState>(
      builder: (context, state) => switch (state) {
        TrackDetailLoading() => const Center(
            child: CircularProgressIndicator(color: AppPalette.primary),
          ),
        TrackDetailNotFound() => _Fallback(
            top: top,
            child: Center(
              child: Text(
                Strings.trackNotFound.i18n,
                textAlign: TextAlign.center,
                style: AppText.sans(15, height: 22),
              ),
            ),
          ),
        TrackDetailInvalidContent(:final issues) =>
          _Fallback(top: top, child: ContentIssueView(issues: issues)),
        TrackDetailLoaded(:final detail) =>
          _TrackDetailBody(detail: detail, top: top),
      },
    );
  }
}

/// Random quick practice: always a fresh session.
void _start(BuildContext context, PracticeTarget target) {
  PracticeRoute(
    setId: target.setId,
    only: target.onlyQuestionIds?.join(','),
  ).push<void>(context);
}

/// Timed mock and topic practice: asks before redoing a completed one.
void _startOrConfirm(BuildContext context, PracticeTarget target) {
  openPractice(
    context,
    setId: target.setId,
    onlyQuestionIds: target.onlyQuestionIds,
  );
}

class _Fallback extends StatelessWidget {
  final Widget top;
  final Widget child;

  const _Fallback({required this.top, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.dsp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          top,
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TrackDetailBody extends StatelessWidget {
  final TrackDetail detail;
  final Widget top;

  const _TrackDetailBody({required this.detail, required this.top});

  @override
  Widget build(BuildContext context) {
    final progress = detail.progress;
    final quick = detail.quickPractice();
    final timed = detail.firstTimedSet;
    final snippet = detail.learning.dailySnippet;

    return Column(
      children: [
        AppProgressBar(
          value: progress.ratio,
          trackColor: Colors.transparent,
          gradient: AppPalette.progressGradient,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.dsp, 12.dsp, 16.dsp, 32.dsp),
            children: [
              top,
              SizedBox(height: 12.dsp),
              TrackHeroCard(
                detail: detail,
                progress: progress,
                onToggleSaved: context.read<TrackDetailCubit>().toggleSaved,
              ),
              if (quick != null) ...[
                SizedBox(height: 24.dsp),
                RandomPracticeButton(
                  questionCount: quick.onlyQuestionIds?.length ??
                      detail.firstFreeSet!.questionCount,
                  subtitle: Strings.trackQuickRandomSubtitle.i18n
                      .fill([detail.track.name.text]),
                  onTap: () => _start(context, quick),
                ),
              ],
              if (timed != null) ...[
                SizedBox(height: 8.dsp),
                TimedMockCard(
                  durationMinutes: timed.set.durationMinutes!,
                  questionCount: timed.questionCount,
                  onStart: () => _startOrConfirm(
                    context,
                    PracticeTarget(setId: timed.set.id),
                  ),
                ),
              ],
              SizedBox(height: 24.dsp),
              TopicSectionHeader(topicCount: progress.topics.length),
              for (final (index, topic) in progress.topics.indexed) ...[
                SizedBox(height: 16.dsp),
                Builder(
                  builder: (context) {
                    final target = detail.topicPractice(topic.topic.id);
                    return TopicModuleCard(
                      index: index + 1,
                      progress: topic,
                      onPractice: target == null
                          ? null
                          : () => _startOrConfirm(context, target),
                    );
                  },
                ),
              ],
              if (snippet != null) ...[
                SizedBox(height: 24.dsp),
                DailySnippetCard(
                  snippet: snippet,
                  onSolve: quick == null ? null : () => _start(context, quick),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

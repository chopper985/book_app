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
import 'package:AppName/core/utils/widgets/app_progress_bar.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';
import 'package:AppName/core/utils/widgets/dev_header.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/daily_snippet_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/topic_module_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_hero_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_quick_actions.dart';
import 'package:AppName/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:AppName/features/content/presentation/widgets/content_issue_view.dart';
import 'package:AppName/features/profile/presentation/extensions/profile_labels.dart';
import 'package:AppName/gen/assets.gen.dart';

/// "Lộ trình Flutter - Chi tiết chủ đề".
class TrackDetailScreen extends StatelessWidget {
  const TrackDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.surface,
      body: BlocBuilder<TrackDetailCubit, TrackDetailState>(
        builder: (context, state) => switch (state) {
          TrackDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          TrackDetailNotFound() => _Fallback(
              child: Center(
                child: Text(
                  Strings.trackNotFound.i18n,
                  textAlign: TextAlign.center,
                  style: AppText.sans(15, height: 22),
                ),
              ),
            ),
          TrackDetailInvalidContent(:final issues) =>
            _Fallback(child: ContentIssueView(issues: issues)),
          TrackDetailLoaded(:final detail) => _TrackDetailBody(detail: detail),
        },
      ),
    );
  }
}

void _back(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    const RoadmapsRoute().go(context);
  }
}

void _start(BuildContext context, PracticeTarget target) {
  PracticeRoute(
    setId: target.setId,
    only: target.onlyQuestionIds?.join(','),
  ).push<void>(context);
}

class _Fallback extends StatelessWidget {
  final Widget child;

  const _Fallback({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.dsp),
            child: const _BackLink(),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TrackDetailBody extends StatelessWidget {
  final TrackDetail detail;

  const _TrackDetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final learner = detail.learning.learner;
    final progress = detail.progress;
    final quick = detail.quickPractice();
    final timed = detail.firstTimedSet;
    final snippet = detail.learning.dailySnippet;

    return Column(
      children: [
        if (learner != null)
          DevHeader(
            roleLabel: learner.experience.headerLabel,
            streakDays: learner.streakDays,
          )
        else
          SizedBox(height: MediaQuery.paddingOf(context).top),
        AppProgressBar(
          value: progress.ratio,
          trackColor: Colors.transparent,
          gradient: AppPalette.progressGradient,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.dsp, 12.dsp, 16.dsp, 32.dsp),
            children: [
              const _BackLink(),
              SizedBox(height: 12.dsp),
              TrackHeroCard(detail: detail, progress: progress),
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
                  onStart: () => _start(
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
                      onPractice:
                          target == null ? null : () => _start(context, target),
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

class _BackLink extends StatelessWidget {
  const _BackLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () => _back(context),
        borderRadius: BorderRadius.circular(6.dsp),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.dsp, horizontal: 4.dsp),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvg(
                Assets.figma.result.back,
                width: 13.33,
                height: 13.33,
                color: AppPalette.onSurfaceVariant,
              ),
              SizedBox(width: 8.dsp),
              Flexible(
                child: Text(
                  Strings.trackBack.i18n,
                  style: AppText.mono(
                    12,
                    height: 16,
                    weight: FontWeight.w500,
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

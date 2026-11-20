// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/navigator/app_router.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/dev_header.dart';
import 'package:AppName/features/catalog/presentation/cubit/explore_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/continue_practice_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/daily_challenge_card.dart';
import 'package:AppName/features/catalog/presentation/widgets/explore_greeting.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_list_section.dart';
import 'package:AppName/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:AppName/features/content/presentation/widgets/content_issue_view.dart';
import 'package:AppName/features/practice/presentation/helpers/practice_launcher.dart';
import 'package:AppName/features/profile/presentation/extensions/profile_labels.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ExploreCubit, ExploreState>(
        builder: (context, state) {
          return switch (state) {
            ExploreLoading() =>
              const Center(child: CircularProgressIndicator()),
            ExploreInvalidContent(:final issues) => SafeArea(
                child: ContentIssueView(
                  issues: issues,
                  onRetry: context.read<ExploreCubit>().load,
                ),
              ),
            ExploreLoaded() => _ExploreBody(state: state),
          };
        },
      ),
    );
  }
}

class _ExploreBody extends StatelessWidget {
  final ExploreLoaded state;

  const _ExploreBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final dashboard = state.dashboard;
    final learner = dashboard.learner;
    final continueSession = dashboard.continueSession;
    final continueTrack = continueSession == null
        ? null
        : state.trackById(continueSession.trackId);
    final challenge = dashboard.dailyChallenge;

    return Column(
      children: [
        DevHeader(
          roleLabel: learner.experience.headerLabel,
          streakDays: learner.streakDays,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.dsp, 4.dsp, 16.dsp, 24.dsp),
            children: [
              ExploreGreeting(learner: learner),
              if (continueSession != null && continueTrack != null) ...[
                SizedBox(height: 24.dsp),
                ContinuePracticeCard(
                  session: continueSession,
                  title: continueTrack.track.name.text,
                  subtitle: continueTrack.track.tagline?.text ?? '',
                  onContinue: () => PracticeRoute(
                    setId: continueSession.setId,
                    sessionId: continueSession.sessionId,
                  ).push<void>(context),
                ),
              ],
              SizedBox(height: 24.dsp),
              RoadmapSectionHeader(
                title: Strings.exploreMyTracks.i18n,
                subtitle: Strings.exploreMyTracksSubtitle.i18n,
                onSeeAll: () => const RoadmapsRoute().go(context),
              ),
              SizedBox(height: 12.dsp),
              RoadmapCardList(
                tracks: state.myTracks,
                completion: dashboard.trackCompletion,
              ),
              if (challenge != null) ...[
                SizedBox(height: 16.dsp),
                DailyChallengeCard(
                  title: challenge.title,
                  rewardXp: challenge.rewardXp,
                  streakDays: learner.streakDays,
                  onSolve: () =>
                      openPractice(context, setId: challenge.setId),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

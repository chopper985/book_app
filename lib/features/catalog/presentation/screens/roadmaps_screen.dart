// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/dev_header.dart';
import 'package:AppName/features/catalog/presentation/cubit/explore_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_list_section.dart';
import 'package:AppName/features/content/presentation/widgets/content_issue_view.dart';

/// "Lộ trình" tab: every track with category filters.
class RoadmapsScreen extends StatelessWidget {
  const RoadmapsScreen({super.key});

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
            ExploreLoaded() => Column(
                children: [
                  DevHeader(
                    roleLabel: state.dashboard.learner.roleLabel,
                    streakDays: state.dashboard.learner.streakDays,
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(16.dsp),
                      children: [
                        RoadmapListSection(state: state, showSeeAll: false),
                      ],
                    ),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}

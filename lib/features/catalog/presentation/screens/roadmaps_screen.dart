// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/injection/injection_container.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/position_detail_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/learner_tab_header.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/position_detail_view.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/roadmap_picker_view.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/roadmap_switcher.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_detail_view.dart';

/// "Lộ trình" tab: asks for a language and a level the first time, then shows
/// the active roadmap (Figma 310:866) with a switcher to change or add one.
class RoadmapsScreen extends StatelessWidget {
  const RoadmapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.surface,
      body: BlocBuilder<RoadmapsCubit, RoadmapsState>(
        builder: (context, state) => switch (state) {
          RoadmapsLoading() => const Center(
              child: CircularProgressIndicator(color: AppPalette.primary),
            ),
          RoadmapsLoaded() => Column(
              children: [
                LearnerTabHeader(
                  learner: state.learner,
                  title: Strings.navRoadmaps.i18n,
                  subtitle: switch (state.active) {
                    null => Strings.pickerTitle.i18n,
                    final active => roadmapLabel(
                        active,
                        state.tracks[active.trackId],
                        state.positions[active.positionId],
                      ),
                  },
                ),
                Expanded(child: _Content(state: state)),
              ],
            ),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final RoadmapsLoaded state;

  const _Content({required this.state});

  @override
  Widget build(BuildContext context) {
    final active = state.active;
    if (active == null) {
      // First visit: choose before anything is shown.
      return BlocProvider(
        create: (_) => getIt<RoadmapPickerCubit>()..load(),
        child: RoadmapPickerView(
          title: Strings.pickerTitle.i18n,
          subtitle: Strings.pickerSubtitle.i18n,
        ),
      );
    }

    final cubit = context.read<RoadmapsCubit>();
    final switcher = RoadmapSwitcher(
      active: active,
      roadmaps: state.roadmaps,
      tracks: state.tracks,
      positions: state.positions,
      onSelect: cubit.select,
      onRemove: cubit.remove,
      onAdd: () => const RoadmapPickerRoute().push<void>(context),
    );
    // A new cubit per roadmap, so switching reloads the detail.
    if (active.isPosition) {
      return BlocProvider(
        key: ValueKey(active.id),
        create: (_) => getIt<PositionDetailCubit>()..load(active),
        child: PositionDetailView(top: switcher),
      );
    }
    return BlocProvider(
      key: ValueKey(active.id),
      create: (_) => getIt<TrackDetailCubit>()
        ..load(active.trackId, maxLevel: active.level),
      child: TrackDetailView(top: switcher),
    );
  }
}

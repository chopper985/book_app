// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/injection/injection_container.dart';
import 'package:AppName/core/navigator/app_router.dart';
import 'package:AppName/core/utils/widgets/dev_header.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_picker_view.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_switcher.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_detail_view.dart';
import 'package:AppName/features/profile/presentation/extensions/profile_labels.dart';

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
                DevHeader(
                  roleLabel: state.learner.experience.headerLabel,
                  streakDays: state.learner.streakDays,
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
    // A new cubit per roadmap, so switching reloads the detail.
    return BlocProvider(
      key: ValueKey(active.id),
      create: (_) => getIt<TrackDetailCubit>()
        ..load(active.trackId, maxLevel: active.level),
      child: TrackDetailView(
        top: RoadmapSwitcher(
          active: active,
          roadmaps: state.roadmaps,
          tracks: state.tracks,
          onSelect: cubit.select,
          onRemove: cubit.remove,
          onAdd: () => const RoadmapPickerRoute().push<void>(context),
        ),
      ),
    );
  }
}

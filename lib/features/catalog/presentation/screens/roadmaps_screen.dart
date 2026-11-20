// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/dev_header.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_list_section.dart';
import 'package:AppName/features/content/presentation/widgets/content_issue_view.dart';
import 'package:AppName/features/profile/presentation/extensions/profile_labels.dart';

/// "Lộ trình" tab: the full library with search, category filter and saved
/// roadmaps.
class RoadmapsScreen extends StatelessWidget {
  const RoadmapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RoadmapsCubit, RoadmapsState>(
        builder: (context, state) {
          return switch (state) {
            RoadmapsLoading() => const Center(
                child: CircularProgressIndicator(color: AppPalette.primary),
              ),
            RoadmapsInvalidContent(:final issues) => SafeArea(
                child: ContentIssueView(
                  issues: issues,
                  onRetry: context.read<RoadmapsCubit>().load,
                ),
              ),
            RoadmapsLoaded() => _Body(state: state),
          };
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final RoadmapsLoaded state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RoadmapsCubit>();
    final completion = state.dashboard.trackCompletion;
    final showSaved = state.savedTracks.isNotEmpty && !state.isFiltering;

    return Column(
      children: [
        DevHeader(
          roleLabel: state.dashboard.learner.experience.headerLabel,
          streakDays: state.dashboard.learner.streakDays,
        ),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16.dsp, 16.dsp, 16.dsp, 24.dsp),
            children: [
              RoadmapSectionHeader(
                title: Strings.roadmapsLibraryTitle.i18n,
                subtitle: Strings.roadmapsLibrarySubtitle.i18n,
              ),
              SizedBox(height: 12.dsp),
              _SearchField(initial: state.query, onChanged: cubit.search),
              SizedBox(height: 12.dsp),
              RoadmapCategoryPills(
                totalCount: state.tracks.length,
                selected: state.category,
                onSelect: cubit.selectCategory,
              ),
              if (showSaved) ...[
                SizedBox(height: 20.dsp),
                RoadmapSectionHeader(title: Strings.roadmapsSaved.i18n),
                SizedBox(height: 12.dsp),
                RoadmapCardList(
                  tracks: state.savedTracks,
                  completion: completion,
                ),
                SizedBox(height: 12.dsp),
                RoadmapSectionHeader(title: Strings.roadmapsLibraryTitle.i18n),
              ],
              SizedBox(height: 12.dsp),
              if (state.visibleTracks.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.dsp),
                  child: Text(
                    Strings.roadmapsNoResult.i18n,
                    textAlign: TextAlign.center,
                    style: AppText.sans(
                      14,
                      height: 20,
                      color: AppPalette.onSurfaceVariant,
                    ),
                  ),
                )
              else
                RoadmapCardList(
                  tracks: state.visibleTracks,
                  completion: completion,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Owns its controller so typing never rebuilds the field from state.
class _SearchField extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.initial, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.dsp),
      borderSide: const BorderSide(color: AppPalette.surfaceHigh),
    );
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      style: AppText.sans(15, height: 22),
      cursorColor: AppPalette.primary,
      decoration: InputDecoration(
        hintText: Strings.roadmapsSearchHint.i18n,
        hintStyle: AppText.sans(
          15,
          height: 22,
          color: AppPalette.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          size: 20.dsp,
          color: AppPalette.onSurfaceVariant,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: Strings.roadmapsClearSearch.i18n,
                  onPressed: _clear,
                  icon: Icon(
                    Icons.close,
                    size: 18.dsp,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
        ),
        filled: true,
        fillColor: AppPalette.surfaceLow,
        contentPadding: EdgeInsets.symmetric(vertical: 12.dsp),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppPalette.primaryStrong),
        ),
      ),
    );
  }
}

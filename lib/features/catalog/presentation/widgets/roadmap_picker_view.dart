// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/position_icon_box.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/roadmap_list_section.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/content/presentation/extensions/question_level_label.dart';
import 'package:interview_practice/features/profile/presentation/widgets/choice_tile.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_form_fields.dart';

/// Language + level picker with search, category filter and saved marks.
/// Used as the empty Roadmaps tab and as the "Add a roadmap" screen.
class RoadmapPickerView extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Shown left of the collapsed title, e.g. a back button.
  final Widget? leading;

  /// Whether the header sits under the status bar (full-screen use). The
  /// Roadmaps tab already has the app header above it.
  final bool primary;

  const RoadmapPickerView({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoadmapPickerCubit, RoadmapPickerState>(
      builder: (context, state) => switch (state) {
        RoadmapPickerLoading() => const Center(
            child: CircularProgressIndicator(color: AppPalette.primary),
          ),
        RoadmapPickerLoaded() => _Body(
            state: state,
            title: title,
            subtitle: subtitle,
            leading: leading,
            primary: primary,
          ),
      },
    );
  }
}

class _Body extends StatelessWidget {
  final RoadmapPickerLoaded state;
  final String title;
  final String subtitle;
  final Widget? leading;
  final bool primary;

  const _Body({
    required this.state,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RoadmapPickerCubit>();
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              _CollapsingHeader(
                title: title,
                subtitle: subtitle,
                leading: leading,
                primary: primary,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 24.dsp),
                sliver: SliverList.list(
                  children: [
                    _ModeSwitch(
                      mode: state.mode,
                      onChanged: cubit.selectMode,
                    ),
                    SizedBox(height: 16.dsp),
                    if (state.mode == RoadmapPickerMode.position)
                      ..._positionPart(context, cubit)
                    else ...[
                      FieldLabel(Strings.pickerLanguage.i18n, required: true),
                      _SearchField(
                        initial: state.query,
                        onChanged: cubit.search,
                      ),
                      SizedBox(height: 12.dsp),
                      RoadmapCategoryPills(
                        totalCount: state.tracks.length,
                        selected: state.category,
                        onSelect: cubit.selectCategory,
                      ),
                      SizedBox(height: 12.dsp),
                      if (state.visibleTracks.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.dsp),
                          child: Text(
                            Strings.roadmapsNoResult.i18n,
                            textAlign: TextAlign.center,
                            style: AppText.sans(
                              14,
                              height: 20,
                              color: AppPalette.onSurfaceVariant,
                            ),
                          ),
                        ),
                      for (final overview in state.visibleTracks) ...[
                        ChoiceTile(
                          title: overview.track.name.text,
                          hint: [
                            if (!overview.track.isAvailable)
                              Strings.onboardingSoon.i18n
                            else if (overview.track.tagline case final tagline?)
                              tagline.text,
                            if (state.savedTrackIds.contains(overview.track.id))
                              '★ ${Strings.roadmapsSaved.i18n}',
                          ].join(' · '),
                          selected: state.selectedTrackId == overview.track.id,
                          leading: Opacity(
                            opacity: overview.track.isAvailable ? 1 : 0.4,
                            child: TrackIconBox(trackId: overview.track.id),
                          ),
                          onTap: () {
                            if (overview.track.isAvailable) {
                              cubit.selectTrack(overview.track.id);
                            } else {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(Strings.comingSoon.i18n),
                                  ),
                                );
                            }
                          },
                        ),
                        SizedBox(height: 8.dsp),
                      ],
                    ],
                    SizedBox(height: 16.dsp),
                    FieldLabel(Strings.pickerLevel.i18n, required: true),
                    Wrap(
                      spacing: 8.dsp,
                      runSpacing: 8.dsp,
                      children: [
                        for (final level in QuestionLevel.values)
                          SelectChip(
                            label: level.isPremium
                                ? '${level.label} · ${Strings.pickerPremium.i18n}'
                                : level.label,
                            selected: state.level == level,
                            onTap: () => cubit.selectLevel(level),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.dsp),
                    Text(
                      state.isExisting
                          ? Strings.pickerExisting.i18n
                          : Strings.pickerLevelHint.i18n,
                      style: AppText.sans(
                        12,
                        height: 16,
                        color: state.isExisting
                            ? AppPalette.teal
                            : AppPalette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _ConfirmButton(
          loading: state.saving,
          onTap: state.canConfirm ? cubit.confirm : null,
        ),
      ],
    );
  }

  List<Widget> _positionPart(BuildContext context, RoadmapPickerCubit cubit) {
    final trackNames = {
      for (final overview in state.tracks)
        overview.track.id: overview.track.name.text,
    };
    return [
      FieldLabel(Strings.pickerPosition.i18n, required: true),
      for (final position in state.positions) ...[
        ChoiceTile(
          title: position.name.text,
          hint: position.description?.text,
          selected: state.positionId == position.id,
          leading: PositionIconBox(positionId: position.id),
          onTap: () => cubit.selectPosition(position.id),
        ),
        SizedBox(height: 8.dsp),
      ],
      if (state.position case final position?) ...[
        SizedBox(height: 8.dsp),
        FieldLabel(Strings.pickerOption.i18n, required: true),
        Wrap(
          spacing: 8.dsp,
          runSpacing: 8.dsp,
          children: [
            for (final option in position.options)
              SelectChip(
                label: option.name.text,
                selected: state.optionId == option.id,
                onTap: () => cubit.selectOption(option.id),
              ),
          ],
        ),
        if (state.positionTrackIds.isNotEmpty) ...[
          SizedBox(height: 8.dsp),
          Text(
            Strings.pickerIncludes.i18n.fill([
              state.positionTrackIds
                  .map((id) => trackNames[id] ?? id)
                  .join(', '),
            ]),
            style: AppText.sans(
              12,
              height: 16,
              color: AppPalette.onSurfaceVariant,
            ),
          ),
        ],
      ],
    ];
  }
}

/// Large title + subtitle that collapse into a pinned app bar with only the
/// title as the list scrolls up.
class _CollapsingHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final bool primary;

  const _CollapsingHeader({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final toolbarHeight = 56.dsp;
    final expandedHeight = 124.dsp;
    final topInset = primary ? MediaQuery.paddingOf(context).top : 0.0;
    final collapsedLeft = leading == null ? 16.dsp : 60.dsp;

    return SliverAppBar(
      pinned: true,
      primary: primary,
      automaticallyImplyLeading: false,
      leading: leading,
      toolbarHeight: toolbarHeight,
      expandedHeight: expandedHeight,
      backgroundColor: AppPalette.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final minExtent = toolbarHeight + topInset;
          final maxExtent = expandedHeight + topInset;
          // 1 = fully expanded, 0 = collapsed into the toolbar.
          final t =
              ((constraints.maxHeight - minExtent) / (maxExtent - minExtent))
                  .clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Collapsed: title alone in the toolbar, after the leading.
              Positioned(
                top: topInset,
                height: toolbarHeight,
                left: collapsedLeft,
                right: 16.dsp,
                child: Opacity(
                  opacity: 1 - t,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(
                        18,
                        height: 26,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              // Expanded: large title and subtitle under the toolbar.
              Positioned(
                left: 16.dsp,
                right: 16.dsp,
                bottom: 8.dsp,
                child: Opacity(
                  opacity: t,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(
                          22,
                          height: 30,
                          weight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.dsp),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(
                          14,
                          height: 20,
                          color: AppPalette.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
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

class _ConfirmButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _ConfirmButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final radius = BorderRadius.circular(8.dsp);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 16.dsp),
      child: Material(
        color: enabled ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: 52.dsp,
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: 20.dsp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppPalette.onPrimaryStrong,
                      ),
                    )
                  : Text(
                      Strings.pickerConfirm.i18n,
                      style: AppText.sans(
                        16,
                        height: 24,
                        weight: FontWeight.w600,
                        color: enabled
                            ? AppPalette.onPrimaryStrong
                            : AppPalette.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final RoadmapPickerMode mode;
  final ValueChanged<RoadmapPickerMode> onChanged;

  const _ModeSwitch({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLow,
        borderRadius: BorderRadius.circular(10.dsp),
        border: Border.all(color: AppPalette.surfaceHigh),
      ),
      child: Row(
        children: [
          for (final (value, label) in [
            (RoadmapPickerMode.language, Strings.pickerModeLanguage),
            (RoadmapPickerMode.position, Strings.pickerModePosition),
          ])
            Expanded(
              child: Semantics(
                selected: mode == value,
                button: true,
                child: Material(
                  color: mode == value
                      ? AppPalette.primaryStrong
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.dsp),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.dsp),
                    onTap: () => onChanged(value),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.dsp),
                      child: Text(
                        label.i18n,
                        textAlign: TextAlign.center,
                        style: AppText.sans(
                          14,
                          height: 20,
                          weight: FontWeight.w600,
                          color: mode == value
                              ? AppPalette.onPrimaryStrong
                              : AppPalette.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

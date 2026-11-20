// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_list_section.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:AppName/features/content/presentation/extensions/question_level_label.dart';
import 'package:AppName/features/profile/presentation/widgets/choice_tile.dart';
import 'package:AppName/features/profile/presentation/widgets/profile_form_fields.dart';

/// Language + level picker with search, category filter and saved marks.
/// Used as the empty Roadmaps tab and as the "Add a roadmap" screen.
class RoadmapPickerView extends StatelessWidget {
  final String title;
  final String subtitle;

  const RoadmapPickerView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoadmapPickerCubit, RoadmapPickerState>(
      builder: (context, state) => switch (state) {
        RoadmapPickerLoading() => const Center(
            child: CircularProgressIndicator(color: AppPalette.primary),
          ),
        RoadmapPickerLoaded() =>
          _Body(state: state, title: title, subtitle: subtitle),
      },
    );
  }
}

class _Body extends StatelessWidget {
  final RoadmapPickerLoaded state;
  final String title;
  final String subtitle;

  const _Body({
    required this.state,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RoadmapPickerCubit>();
    return Column(
      children: [
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(16.dsp, 16.dsp, 16.dsp, 24.dsp),
            children: [
              Text(
                title,
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
                style: AppText.sans(
                  14,
                  height: 20,
                  color: AppPalette.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20.dsp),
              FieldLabel(Strings.pickerLanguage.i18n, required: true),
              _SearchField(initial: state.query, onChanged: cubit.search),
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
                          SnackBar(content: Text(Strings.comingSoon.i18n)),
                        );
                    }
                  },
                ),
                SizedBox(height: 8.dsp),
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
        _ConfirmButton(
          loading: state.saving,
          onTap: state.canConfirm ? cubit.confirm : null,
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

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/entities/user_roadmap.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:AppName/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:AppName/features/content/presentation/extensions/question_level_label.dart';

/// "Flutter · Fresher / Junior": the roadmap name and its level range.
String roadmapLabel(UserRoadmap roadmap, TrackOverview? overview) {
  final name = overview?.track.name.text ?? roadmap.trackId;
  final levels = roadmap.levels.map((level) => level.label).join(' / ');
  return '$name · $levels';
}

/// Current roadmap button above the hero card; opens the roadmap list.
class RoadmapSwitcher extends StatelessWidget {
  final UserRoadmap active;
  final List<UserRoadmap> roadmaps;
  final Map<String, TrackOverview> tracks;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onRemove;
  final VoidCallback onAdd;

  const RoadmapSwitcher({
    super.key,
    required this.active,
    required this.roadmaps,
    required this.tracks,
    required this.onSelect,
    required this.onRemove,
    required this.onAdd,
  });

  Future<void> _open(BuildContext context) async {
    final action = await showModalBottomSheet<_SheetAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.dsp)),
      ),
      builder: (context) => _RoadmapSheet(
        active: active,
        roadmaps: roadmaps,
        tracks: tracks,
      ),
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case _Select(:final id):
        onSelect(id);
      case _Remove(:final id):
        if (await _confirmRemove(context)) onRemove(id);
      case _Add():
        onAdd();
    }
  }

  static Future<bool> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surfaceContainer,
        title: Text(
          Strings.switcherRemoveTitle.i18n,
          style: AppText.sans(18, height: 26, weight: FontWeight.w600),
        ),
        content: Text(
          Strings.switcherRemoveMessage.i18n,
          style: AppText.sans(
            14,
            height: 20,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              Strings.switcherRemoveCancel.i18n,
              style: AppText.sans(14, weight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Strings.switcherRemoveConfirm.i18n,
              style: AppText.sans(
                14,
                weight: FontWeight.w600,
                color: AppPalette.error,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Material(
      color: AppPalette.surfaceLow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: AppPalette.surfaceHigh),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => _open(context),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.dsp, vertical: 10.dsp),
          child: Row(
            children: [
              TrackIconBox(trackId: active.trackId, size: 32),
              SizedBox(width: 10.dsp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.switcherLabel.i18n,
                      style: AppText.mono(10, height: 14),
                    ),
                    Text(
                      roadmapLabel(active, tracks[active.trackId]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(
                        14,
                        height: 20,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.unfold_more,
                size: 20.dsp,
                color: AppPalette.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

sealed class _SheetAction {
  const _SheetAction();
}

class _Select extends _SheetAction {
  final String id;

  const _Select(this.id);
}

class _Remove extends _SheetAction {
  final String id;

  const _Remove(this.id);
}

class _Add extends _SheetAction {
  const _Add();
}

class _RoadmapSheet extends StatelessWidget {
  final UserRoadmap active;
  final List<UserRoadmap> roadmaps;
  final Map<String, TrackOverview> tracks;

  const _RoadmapSheet({
    required this.active,
    required this.roadmaps,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 12.dsp),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.dsp, 4.dsp, 16.dsp, 8.dsp),
              child: Text(
                Strings.switcherTitle.i18n,
                style: AppText.sans(18, height: 26, weight: FontWeight.w600),
              ),
            ),
            for (final roadmap in roadmaps)
              ListTile(
                leading: TrackIconBox(trackId: roadmap.trackId, size: 32),
                title: Text(
                  roadmapLabel(roadmap, tracks[roadmap.trackId]),
                  style: AppText.sans(
                    14,
                    height: 20,
                    weight: FontWeight.w600,
                    color: roadmap.id == active.id
                        ? AppPalette.primary
                        : AppPalette.onSurface,
                  ),
                ),
                selected: roadmap.id == active.id,
                onTap: () => Navigator.of(context).pop(_Select(roadmap.id)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (roadmap.id == active.id)
                      Icon(
                        Icons.check_circle,
                        size: 20.dsp,
                        color: AppPalette.primaryStrong,
                      ),
                    IconButton(
                      tooltip: Strings.switcherRemove.i18n,
                      onPressed: () =>
                          Navigator.of(context).pop(_Remove(roadmap.id)),
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20.dsp,
                        color: AppPalette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(color: AppPalette.surfaceHigh),
            ListTile(
              leading: Icon(
                Icons.add_circle_outline,
                size: 24.dsp,
                color: AppPalette.primary,
              ),
              title: Text(
                Strings.switcherAdd.i18n,
                style: AppText.sans(
                  15,
                  height: 22,
                  weight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              onTap: () => Navigator.of(context).pop(const _Add()),
            ),
          ],
        ),
      ),
    );
  }
}

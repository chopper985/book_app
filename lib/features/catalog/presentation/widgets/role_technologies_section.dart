// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/domain/entities/role_technologies.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/position_icon_box.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/roadmap_list_section.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';

/// "Technologies by role": pick Mobile / Front-end / Back-end / Tester and
/// see the languages to choose from plus the shared knowledge; each one can
/// be added to the roadmaps or tried with a short practice.
class RoleTechnologiesSection extends StatelessWidget {
  final List<RoleTechnologies> roles;
  final RoleTechnologies selected;
  final ValueChanged<String> onSelectRole;

  /// Track ids already in the learner's roadmaps.
  final Set<String> addedTrackIds;

  /// Every track, to name a framework's languages and runtime.
  final List<TrackOverview> allTracks;
  final ValueChanged<TrackOverview> onAdd;
  final ValueChanged<TrackOverview> onTry;

  const RoleTechnologiesSection({
    super.key,
    required this.roles,
    required this.selected,
    required this.onSelectRole,
    required this.addedTrackIds,
    required this.onAdd,
    required this.onTry,
    this.allTracks = const [],
  });

  /// "JavaScript / TypeScript · Node.js" for a framework, `null` otherwise.
  String? _stackOf(TrackOverview overview) {
    final track = overview.track;
    if (!track.isFramework) return null;
    String name(String id) {
      for (final other in allTracks) {
        if (other.track.id == id) return other.track.name.text;
      }
      return id;
    }

    final languages = track.languages.map(name).join(' / ');
    final runtime = track.runtime;
    return runtime == null ? languages : '$languages · ${name(runtime)}';
  }

  @override
  Widget build(BuildContext context) {
    final description = selected.position.description?.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoadmapSectionHeader(
          title: Strings.exploreRolesTitle.i18n,
          subtitle: Strings.exploreRolesSubtitle.i18n,
        ),
        SizedBox(height: 12.dsp),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final role in roles) ...[
                _RolePill(
                  role: role,
                  selected: role.position.id == selected.position.id,
                  onTap: () => onSelectRole(role.position.id),
                ),
                SizedBox(width: 8.dsp),
              ],
            ],
          ),
        ),
        if (description != null && description.isNotEmpty) ...[
          SizedBox(height: 12.dsp),
          Text(
            description,
            style: AppText.sans(
              13,
              height: 18,
              color: AppPalette.onSurfaceVariant,
            ),
          ),
        ],
        if (selected.main.isNotEmpty) ...[
          SizedBox(height: 12.dsp),
          _GroupLabel(Strings.exploreRoleMain.i18n),
          _TechList(
            tracks: selected.main,
            addedTrackIds: addedTrackIds,
            stackOf: _stackOf,
            onAdd: onAdd,
            onTry: onTry,
          ),
        ],
        if (selected.shared.isNotEmpty) ...[
          SizedBox(height: 12.dsp),
          _GroupLabel(Strings.exploreRoleShared.i18n),
          _TechList(
            tracks: selected.shared,
            addedTrackIds: addedTrackIds,
            stackOf: _stackOf,
            onAdd: onAdd,
            onTry: onTry,
          ),
        ],
      ],
    );
  }
}

class _RolePill extends StatelessWidget {
  final RoleTechnologies role;
  final bool selected;
  final VoidCallback onTap;

  const _RolePill({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);
    return Material(
      color: selected ? AppPalette.primaryContainer : AppPalette.surfaceLow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(6.dsp, 6.dsp, 12.dsp, 6.dsp),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PositionIconBox(positionId: role.position.id, size: 24),
              SizedBox(width: 6.dsp),
              Text(
                role.position.name.text,
                style: AppText.sans(
                  13,
                  height: 18,
                  weight: FontWeight.w600,
                  color: selected ? AppPalette.primary : AppPalette.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.dsp),
      child: Text(
        text.toUpperCase(),
        style: AppText.mono(11, height: 16, letterSpacing: 0.8),
      ),
    );
  }
}

class _TechList extends StatelessWidget {
  final List<TrackOverview> tracks;
  final Set<String> addedTrackIds;
  final String? Function(TrackOverview overview) stackOf;
  final ValueChanged<TrackOverview> onAdd;
  final ValueChanged<TrackOverview> onTry;

  const _TechList({
    required this.tracks,
    required this.addedTrackIds,
    required this.stackOf,
    required this.onAdd,
    required this.onTry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final overview in tracks) ...[
          _TechRow(
            overview: overview,
            added: addedTrackIds.contains(overview.track.id),
            stack: stackOf(overview),
            onAdd: () => onAdd(overview),
            onTry: () => onTry(overview),
          ),
          SizedBox(height: 8.dsp),
        ],
      ],
    );
  }
}

/// Logo, name and question count, with "Add" and "Try" actions.
class _TechRow extends StatelessWidget {
  final TrackOverview overview;
  final bool added;

  /// Languages and runtime of a framework, e.g. "JavaScript / TypeScript ·
  /// Node.js".
  final String? stack;
  final VoidCallback onAdd;
  final VoidCallback onTry;

  const _TechRow({
    required this.overview,
    required this.added,
    required this.stack,
    required this.onAdd,
    required this.onTry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.dsp, 8.dsp, 8.dsp, 8.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLow,
        borderRadius: BorderRadius.circular(8.dsp),
        border: Border.all(color: AppPalette.surfaceHigh),
      ),
      child: Row(
        children: [
          TrackIconBox(trackId: overview.track.id, size: 32),
          SizedBox(width: 10.dsp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overview.track.name.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(14, height: 20, weight: FontWeight.w600),
                ),
                if (stack != null)
                  Text(
                    stack!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppText.mono(10, height: 14, color: AppPalette.primary),
                  ),
                Text(
                  Strings.exploreRoleQuestions.i18n
                      .fill([overview.questionCount]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(
                    11,
                    height: 16,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.dsp),
          _SmallAction(
            icon: added ? Icons.check_rounded : Icons.add_rounded,
            label: added
                ? Strings.exploreRoleAdded.i18n
                : Strings.exploreRoleAdd.i18n,
            filled: false,
            onTap: added ? null : onAdd,
          ),
          SizedBox(width: 6.dsp),
          _SmallAction(
            icon: Icons.play_arrow_rounded,
            label: Strings.exploreRoleTry.i18n,
            filled: true,
            onTap: onTry,
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _SmallAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final foreground = filled
        ? AppPalette.onPrimaryStrong
        : (enabled ? AppPalette.primary : AppPalette.teal);
    final radius = BorderRadius.circular(8.dsp);
    return Material(
      color: filled ? AppPalette.primaryStrong : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: filled
            ? BorderSide.none
            : BorderSide(
                color:
                    enabled ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
              ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.dsp, vertical: 6.dsp),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.dsp, color: foreground),
              SizedBox(width: 2.dsp),
              Text(
                label,
                style: AppText.sans(
                  12,
                  height: 16,
                  weight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

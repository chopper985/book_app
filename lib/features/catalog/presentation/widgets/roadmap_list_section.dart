// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_card.dart';
import 'package:AppName/gen/assets.gen.dart';

/// Section title with an optional subtitle and "See all" button.
class RoadmapSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const RoadmapSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.sans(
                  16,
                  height: 24,
                  weight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppText.sans(
                    12,
                    height: 18,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (onSeeAll != null) ...[
          SizedBox(width: 8.dsp),
          _SeeAllButton(onTap: onSeeAll!),
        ],
      ],
    );
  }
}

/// Horizontal category filter; `null` is "All".
class RoadmapCategoryPills extends StatelessWidget {
  final int totalCount;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const RoadmapCategoryPills({
    super.key,
    required this.totalCount,
    required this.selected,
    required this.onSelect,
  });

  static const List<(String?, String)> _categories = [
    (null, Strings.allCount),
    ('mobile', Strings.categoryMobile),
    ('frontend', Strings.categoryFrontend),
    ('backend', Strings.categoryBackend),
    ('systems', Strings.categorySystems),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (category, label) in _categories) ...[
            _CategoryPill(
              label: category == null
                  ? label.i18n.fill([totalCount])
                  : label.i18n,
              selected: selected == category,
              onTap: () => onSelect(category),
            ),
            SizedBox(width: 4.dsp),
          ],
        ],
      ),
    );
  }
}

/// Track cards; [onOpen] for available tracks, "coming soon" otherwise.
class RoadmapCardList extends StatelessWidget {
  final List<TrackOverview> tracks;

  /// Completed ratio (0..1) per track id.
  final Map<String, double> completion;
  final ValueChanged<TrackOverview> onOpen;

  const RoadmapCardList({
    super.key,
    required this.tracks,
    required this.completion,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final overview in tracks) ...[
          RoadmapCard(
            overview: overview,
            completion: completion[overview.track.id] ?? 0,
            onTap: () {
              if (overview.track.isAvailable) {
                onOpen(overview);
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
      ],
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SeeAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.surfaceHigh,
      borderRadius: BorderRadius.circular(4.dsp),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.dsp),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.dsp, vertical: 6.dsp),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Strings.seeAll.i18n,
                style: AppText.mono(10, height: 14, color: AppPalette.primary),
              ),
              SizedBox(width: 4.dsp),
              AppSvg(
                Assets.figma.explore.icArrowRight,
                width: 8,
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppPalette.surfaceBright : AppPalette.surfaceLow,
      borderRadius: BorderRadius.circular(8.dsp),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.dsp),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.dsp, vertical: 6.dsp),
          child: Text(
            label,
            style: AppText.mono(
              10,
              height: 14,
              weight: selected ? FontWeight.w500 : FontWeight.w600,
              color:
                  selected ? AppPalette.onSurface : AppPalette.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

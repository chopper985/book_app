// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/navigator/app_router.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';
import 'package:AppName/features/catalog/presentation/cubit/explore_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_card.dart';
import 'package:AppName/gen/assets.gen.dart';

/// "Lộ trình phỏng vấn trọng điểm": header, category pills and track cards.
class RoadmapListSection extends StatelessWidget {
  final ExploreLoaded state;
  final bool showSeeAll;

  const RoadmapListSection({
    super.key,
    required this.state,
    this.showSeeAll = true,
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
    final cubit = context.read<ExploreCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.roadmapsTitle.i18n,
                    style: AppText.sans(
                      16,
                      height: 24,
                      weight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    Strings.roadmapsSubtitle.i18n,
                    style: AppText.sans(
                      12,
                      height: 18,
                      color: AppPalette.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (showSeeAll) ...[
              SizedBox(width: 8.dsp),
              _SeeAllButton(onTap: () => const RoadmapsRoute().go(context)),
            ],
          ],
        ),
        SizedBox(height: 16.dsp),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final (category, label) in _categories) ...[
                _CategoryPill(
                  label: category == null
                      ? label.i18n.fill([state.tracks.length])
                      : label.i18n,
                  selected: state.category == category,
                  onTap: () => cubit.selectCategory(category),
                ),
                SizedBox(width: 4.dsp),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.dsp),
        for (final overview in state.visibleTracks) ...[
          RoadmapCard(
            overview: overview,
            completion: state.dashboard.trackCompletion[overview.track.id] ?? 0,
            onTap: () {
              if (overview.track.isAvailable) {
                TrackDetailRoute(trackId: overview.track.id).go(context);
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

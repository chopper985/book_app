// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';

/// Tab scaffold with the bottom navigation of the design.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static const List<_NavItem> _items = [
    _NavItem(Strings.navExplore, 'assets/figma/nav/ic_explore.svg', 16.67, 16.67),
    _NavItem(Strings.navRoadmaps, 'assets/figma/nav/ic_roadmap.svg', 15, 16.67),
    _NavItem(Strings.navPractice, 'assets/figma/nav/ic_practice.svg', 16.67, 13.33),
    _NavItem(Strings.navProfile, 'assets/figma/nav/ic_profile.svg', 13.33, 13.33),
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppPalette.surfaceLowest.withValues(alpha: 0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 12,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64.dsp,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.dsp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _items.length; i++)
                    _NavButton(
                      item: _items[i],
                      selected: i == navigationShell.currentIndex,
                      onTap: () => _onTap(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String icon;
  final double width;
  final double height;

  const _NavItem(this.label, this.icon, this.width, this.height);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppPalette.primary : AppPalette.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label.i18n,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.dsp),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 44.dsp, minHeight: 44.dsp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.dsp,
                height: 28.dsp,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppPalette.primary.withValues(alpha: 0.1)
                      : null,
                  borderRadius: BorderRadius.circular(8.dsp),
                ),
                child: AppSvg(
                  item.icon,
                  width: item.width,
                  height: item.height,
                  color: color,
                ),
              ),
              SizedBox(height: 2.dsp),
              Text(
                item.label.i18n,
                style: AppText.mono(10, height: 14, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

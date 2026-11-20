// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/gen/assets.gen.dart';

/// Per-track icon and accent colors from the Explore design.
class TrackStyle {
  final String icon;
  final Size iconSize;
  final String metaIcon;
  final Size metaIconSize;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color percentColor;
  final Color barColor;

  const TrackStyle({
    required this.icon,
    required this.iconSize,
    required this.metaIcon,
    required this.metaIconSize,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.percentColor,
    required this.barColor,
  });

  static final Map<String, TrackStyle> _styles = {
    'flutter': TrackStyle(
      icon: Assets.figma.explore.icTrackFlutter,
      iconSize: Size(17.78, 22),
      metaIcon: Assets.figma.explore.icMetaFlutter,
      metaIconSize: Size(11, 9),
      badgeBackground: AppPalette.tealContainer,
      badgeForeground: AppPalette.teal,
      percentColor: AppPalette.primary,
      barColor: AppPalette.primary,
    ),
    'dart': TrackStyle(
      icon: Assets.figma.explore.icTrackDart,
      iconSize: Size(18, 18),
      metaIcon: Assets.figma.explore.icMetaDart,
      metaIconSize: Size(11, 10.5),
      badgeBackground: AppPalette.surfaceBright,
      badgeForeground: AppPalette.onSurface,
      percentColor: AppPalette.teal,
      barColor: AppPalette.teal,
    ),
    'react_ts': TrackStyle(
      icon: Assets.figma.explore.icTrackReactTs,
      iconSize: Size(20, 16),
      metaIcon: Assets.figma.explore.icMetaReactTs,
      metaIconSize: Size(10, 9.5),
      badgeBackground: AppPalette.errorContainer,
      badgeForeground: AppPalette.error,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.primaryStrong,
    ),
    'dotnet': TrackStyle(
      icon: Assets.figma.explore.icTrackDotnet,
      iconSize: Size(18, 18),
      metaIcon: Assets.figma.explore.icMetaDotnet,
      metaIconSize: Size(10, 9),
      badgeBackground: AppPalette.purpleContainer,
      badgeForeground: AppPalette.purple,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.purple,
    ),
    'go': TrackStyle(
      icon: Assets.figma.explore.icTrackGo,
      iconSize: Size(16, 20),
      metaIcon: Assets.figma.explore.icMetaGo,
      metaIconSize: Size(9, 9),
      badgeBackground: AppPalette.tealContainer,
      badgeForeground: AppPalette.teal,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.tealDeep,
    ),
    'rust': TrackStyle(
      icon: Assets.figma.explore.icTrackRust,
      iconSize: Size(16, 20),
      metaIcon: Assets.figma.explore.icMetaRust,
      metaIconSize: Size(9.26, 9.01),
      badgeBackground: AppPalette.surfaceBright,
      badgeForeground: AppPalette.purple,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.purpleDeep,
    ),
  };

  static TrackStyle of(String trackId) => _styles[trackId] ?? _styles['dart']!;
}

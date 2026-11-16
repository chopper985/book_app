// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';

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

  static const String _dir = 'assets/figma/explore';

  static const Map<String, TrackStyle> _styles = {
    'flutter': TrackStyle(
      icon: '$_dir/ic_track_flutter.svg',
      iconSize: Size(17.78, 22),
      metaIcon: '$_dir/ic_meta_flutter.svg',
      metaIconSize: Size(11, 9),
      badgeBackground: AppPalette.tealContainer,
      badgeForeground: AppPalette.teal,
      percentColor: AppPalette.primary,
      barColor: AppPalette.primary,
    ),
    'dart': TrackStyle(
      icon: '$_dir/ic_track_dart.svg',
      iconSize: Size(18, 18),
      metaIcon: '$_dir/ic_meta_dart.svg',
      metaIconSize: Size(11, 10.5),
      badgeBackground: AppPalette.surfaceBright,
      badgeForeground: AppPalette.onSurface,
      percentColor: AppPalette.teal,
      barColor: AppPalette.teal,
    ),
    'react_ts': TrackStyle(
      icon: '$_dir/ic_track_react_ts.svg',
      iconSize: Size(20, 16),
      metaIcon: '$_dir/ic_meta_react_ts.svg',
      metaIconSize: Size(10, 9.5),
      badgeBackground: AppPalette.errorContainer,
      badgeForeground: AppPalette.error,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.primaryStrong,
    ),
    'dotnet': TrackStyle(
      icon: '$_dir/ic_track_dotnet.svg',
      iconSize: Size(18, 18),
      metaIcon: '$_dir/ic_meta_dotnet.svg',
      metaIconSize: Size(10, 9),
      badgeBackground: AppPalette.purpleContainer,
      badgeForeground: AppPalette.purple,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.purple,
    ),
    'go': TrackStyle(
      icon: '$_dir/ic_track_go.svg',
      iconSize: Size(16, 20),
      metaIcon: '$_dir/ic_meta_go.svg',
      metaIconSize: Size(9, 9),
      badgeBackground: AppPalette.tealContainer,
      badgeForeground: AppPalette.teal,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.tealDeep,
    ),
    'rust': TrackStyle(
      icon: '$_dir/ic_track_rust.svg',
      iconSize: Size(16, 20),
      metaIcon: '$_dir/ic_meta_rust.svg',
      metaIconSize: Size(9.26, 9.01),
      badgeBackground: AppPalette.surfaceBright,
      badgeForeground: AppPalette.purple,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.purpleDeep,
    ),
  };

  static TrackStyle of(String trackId) => _styles[trackId] ?? _styles['dart']!;
}

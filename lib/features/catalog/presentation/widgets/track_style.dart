// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Text badge used when a track has no Figma icon: brand color text on an
/// optional brand background (e.g. black "JS" on yellow).
class TrackMonogram {
  final String text;
  final Color color;
  final Color? background;

  const TrackMonogram(this.text, {required this.color, this.background});
}

/// Per-track icon and accent colors from the Explore design.
class TrackStyle {
  /// Figma SVG; `null` uses [monogram].
  final String? icon;
  final Size iconSize;
  final String? metaIcon;
  final Size metaIconSize;
  final TrackMonogram? monogram;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color percentColor;
  final Color barColor;

  const TrackStyle({
    this.icon,
    this.iconSize = const Size(20, 20),
    this.metaIcon,
    this.metaIconSize = const Size(10, 10),
    this.monogram,
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
    'react_native': TrackStyle(
      monogram: TrackMonogram('RN', color: Color(0xFF61DAFB)),
      badgeBackground: AppPalette.primaryContainer,
      badgeForeground: AppPalette.primary,
      percentColor: AppPalette.primary,
      barColor: Color(0xFF61DAFB),
    ),
    'javascript': TrackStyle(
      monogram: TrackMonogram(
        'JS',
        color: Color(0xFF1B1B1B),
        background: Color(0xFFF7DF1E),
      ),
      badgeBackground: Color(0x33F7DF1E),
      badgeForeground: Color(0xFFF7DF1E),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFFF7DF1E),
    ),
    'nodejs': TrackStyle(
      monogram: TrackMonogram('node', color: Color(0xFF8CC84B)),
      badgeBackground: Color(0x338CC84B),
      badgeForeground: Color(0xFF8CC84B),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFF8CC84B),
    ),
    'java': TrackStyle(
      monogram: TrackMonogram('Java', color: Color(0xFFF89820)),
      badgeBackground: Color(0x33F89820),
      badgeForeground: Color(0xFFF89820),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFFF89820),
    ),
    'swift': TrackStyle(
      monogram: TrackMonogram('Swift', color: Color(0xFFF05138)),
      badgeBackground: AppPalette.errorContainer,
      badgeForeground: Color(0xFFFF8A73),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFFF05138),
    ),
    'php': TrackStyle(
      monogram: TrackMonogram('PHP', color: Color(0xFFA5A9E8)),
      badgeBackground: Color(0x33777BB4),
      badgeForeground: Color(0xFFA5A9E8),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFF777BB4),
    ),
    'kotlin': TrackStyle(
      monogram: TrackMonogram('K', color: Color(0xFFB794F6)),
      badgeBackground: AppPalette.purpleContainer,
      badgeForeground: AppPalette.purple,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFF7F52FF),
    ),
    'typescript': TrackStyle(
      monogram: TrackMonogram(
        'TS',
        color: Color(0xFFFFFFFF),
        background: Color(0xFF3178C6),
      ),
      badgeBackground: Color(0x333178C6),
      badgeForeground: Color(0xFF7FB2F0),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFF3178C6),
    ),
    'python': TrackStyle(
      monogram: TrackMonogram('Py', color: Color(0xFFFFD43B)),
      badgeBackground: Color(0x33FFD43B),
      badgeForeground: Color(0xFFFFD43B),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFF4B8BBE),
    ),
    'sql': TrackStyle(
      monogram: TrackMonogram('SQL', color: AppPalette.teal),
      badgeBackground: AppPalette.tealContainer,
      badgeForeground: AppPalette.teal,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.tealDeep,
    ),
    'http_api': TrackStyle(
      monogram: TrackMonogram('API', color: AppPalette.primary),
      badgeBackground: AppPalette.primaryContainer,
      badgeForeground: AppPalette.primary,
      percentColor: AppPalette.onSurfaceVariant,
      barColor: AppPalette.primaryStrong,
    ),
    'git': TrackStyle(
      monogram: TrackMonogram('git', color: Color(0xFFF05032)),
      badgeBackground: AppPalette.errorContainer,
      badgeForeground: Color(0xFFFF8A73),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFFF05032),
    ),
    'testing': TrackStyle(
      monogram: TrackMonogram('QA', color: Color(0xFF8CE99A)),
      badgeBackground: Color(0x338CE99A),
      badgeForeground: Color(0xFF8CE99A),
      percentColor: AppPalette.onSurfaceVariant,
      barColor: Color(0xFF51CF66),
    ),
  };

  static TrackStyle of(String trackId) =>
      _styles[trackId] ??
      TrackStyle(
        monogram: TrackMonogram(
          trackId.length <= 2 ? trackId.toUpperCase() : trackId.substring(0, 2),
          color: AppPalette.primary,
        ),
        badgeBackground: AppPalette.surfaceBright,
        badgeForeground: AppPalette.onSurface,
        percentColor: AppPalette.onSurfaceVariant,
        barColor: AppPalette.primary,
      );
}

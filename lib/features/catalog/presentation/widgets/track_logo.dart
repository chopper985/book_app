// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_style.dart';

/// The track's logo without a frame: its Figma SVG, or a brand-colored text
/// badge when there is none. [scale] grows it for larger frames.
class TrackLogo extends StatelessWidget {
  final String trackId;
  final double scale;

  /// Draws the small meta icon of the track cards instead of the main logo.
  final bool meta;

  const TrackLogo({
    super.key,
    required this.trackId,
    this.scale = 1,
    this.meta = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TrackStyle.of(trackId);
    final svg = meta ? style.metaIcon : style.icon;
    final size = meta ? style.metaIconSize : style.iconSize;
    if (svg != null) {
      return AppSvg(
        svg,
        width: size.width * scale,
        height: size.height * scale,
      );
    }
    if (meta) {
      return Icon(
        Icons.code,
        size: 11.dsp * scale,
        color: AppPalette.onSurfaceVariant,
      );
    }

    final monogram = style.monogram!;
    // Fits the text in the same box an SVG logo would take.
    final box = 22.dsp * scale;
    return Container(
      width: box,
      height: box,
      alignment: Alignment.center,
      padding: EdgeInsets.all(2.dsp * scale),
      decoration: monogram.background == null
          ? null
          : BoxDecoration(
              color: monogram.background,
              borderRadius: BorderRadius.circular(4.dsp * scale),
            ),
      child: FittedBox(
        child: Text(
          monogram.text,
          maxLines: 1,
          style: AppText.mono(
            12,
            height: 14,
            weight: FontWeight.w700,
            color: monogram.color,
          ),
        ),
      ),
    );
  }
}

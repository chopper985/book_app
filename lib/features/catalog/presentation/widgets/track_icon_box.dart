// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_style.dart';

/// Track logo on a rounded square.
class TrackIconBox extends StatelessWidget {
  final String trackId;
  final double size;

  const TrackIconBox({super.key, required this.trackId, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final style = TrackStyle.of(trackId);
    return Container(
      width: size.dsp,
      height: size.dsp,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: AppSvg(
        style.icon,
        width: style.iconSize.width,
        height: style.iconSize.height,
      ),
    );
  }
}

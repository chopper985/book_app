// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// Project imports:
import 'package:AppName/core/utils/sizer/design_size.dart';

/// SVG asset sized in Figma px. [color] recolors single-color icons.
class AppSvg extends StatelessWidget {
  final String asset;
  final double width;
  final double height;
  final Color? color;

  const AppSvg(
    this.asset, {
    super.key,
    required this.width,
    required this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: width.dsp,
      height: height.dsp,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

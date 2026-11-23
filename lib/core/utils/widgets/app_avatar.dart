// Dart imports:
import 'dart:io';

// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Round avatar: the image at [path], or the first letter of [name].
class AppAvatar extends StatelessWidget {
  final String? path;
  final String name;
  final double size;

  const AppAvatar({
    super.key,
    required this.path,
    required this.name,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final dimension = size.dsp;
    final file = path;
    return Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppPalette.progressGradient,
      ),
      child: file == null
          ? Text(
              trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase(),
              style: AppText.sans(
                size * 0.43,
                height: size * 0.57,
                weight: FontWeight.w700,
                color: AppPalette.onPrimaryStrong,
              ),
            )
          : Image.file(
              File(file),
              width: dimension,
              height: dimension,
              fit: BoxFit.cover,
              // Decode at display size instead of the full photo.
              cacheWidth:
                  (dimension * MediaQuery.devicePixelRatioOf(context)).round(),
              errorBuilder: (context, _, __) => Icon(
                Icons.person,
                size: dimension * 0.5,
                color: AppPalette.onPrimaryStrong,
              ),
            ),
    );
  }
}

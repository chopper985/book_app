// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_logo.dart';

/// Track logo on a rounded square.
class TrackIconBox extends StatelessWidget {
  final String trackId;
  final double size;

  const TrackIconBox({super.key, required this.trackId, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.dsp,
      height: size.dsp,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: TrackLogo(trackId: trackId, scale: size / 36),
    );
  }
}

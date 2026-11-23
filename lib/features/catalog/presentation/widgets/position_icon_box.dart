// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Role icon of a job position on a rounded square.
class PositionIconBox extends StatelessWidget {
  final String positionId;
  final double size;

  const PositionIconBox({super.key, required this.positionId, this.size = 36});

  static IconData iconOf(String positionId) => switch (positionId) {
        'mobile' => Icons.phone_android,
        'frontend' => Icons.web,
        'backend' => Icons.dns_outlined,
        'tester' => Icons.bug_report_outlined,
        _ => Icons.work_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.dsp,
      height: size.dsp,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppPalette.primaryContainer,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Icon(
        iconOf(positionId),
        size: size.dsp * 0.55,
        color: AppPalette.primary,
      ),
    );
  }
}

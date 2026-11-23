// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Placeholder avatar of the practice and result headers.
class DevAvatar extends StatelessWidget {
  final double size;

  const DevAvatar({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.dsp),
      child: Image.asset(
        'assets/images/figma/avatar.jpg',
        width: size.dsp,
        height: size.dsp,
        fit: BoxFit.cover,
      ),
    );
  }
}

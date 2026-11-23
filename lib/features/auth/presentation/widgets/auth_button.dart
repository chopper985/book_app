// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Full-width button of the sign-in screens: filled (primary action) or
/// outlined, with an optional leading icon and a loading state.
class AuthButton extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool filled;
  final bool loading;
  final VoidCallback? onTap;

  const AuthButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    final radius = BorderRadius.circular(8.dsp);
    final background = filled
        ? (enabled ? AppPalette.primaryStrong : AppPalette.surfaceHigh)
        : AppPalette.surfaceLow;
    final foreground = filled
        ? (enabled ? AppPalette.onPrimaryStrong : AppPalette.onSurfaceVariant)
        : AppPalette.onSurface;
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: filled
            ? BorderSide.none
            : const BorderSide(color: AppPalette.surfaceHigh),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: 52.dsp,
          child: Center(
            child: loading
                ? SizedBox.square(
                    dimension: 20.dsp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[icon!, SizedBox(width: 10.dsp)],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sans(
                            15,
                            height: 22,
                            weight: FontWeight.w600,
                            color: foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

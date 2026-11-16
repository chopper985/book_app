// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/core/utils/widgets/app_svg.dart';

/// App header of the tab screens: logo, role, streak chip and avatar.
class DevHeader extends StatelessWidget {
  final String roleLabel;
  final int streakDays;

  const DevHeader({
    super.key,
    required this.roleLabel,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceLowest.withValues(alpha: 0.8),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 1)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64.dsp,
          padding: EdgeInsets.symmetric(horizontal: 16.dsp),
          child: Row(
            children: [
              Image.asset(
                'assets/images/figma/logo.jpg',
                width: 58.72.dsp,
                height: 32.dsp,
                fit: BoxFit.fill,
              ),
              SizedBox(width: 8.dsp),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.appName.i18n,
                    style: AppText.mono(
                      13,
                      height: 20,
                      weight: FontWeight.w700,
                      color: AppPalette.primary,
                      letterSpacing: -0.325,
                    ),
                  ),
                  Row(
                    children: [
                      _Dot(size: 6),
                      SizedBox(width: 4.dsp),
                      Text(roleLabel, style: AppText.mono(10, height: 14)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.dsp,
                  vertical: 4.dsp,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.surfaceHigh,
                  borderRadius: BorderRadius.circular(8.dsp),
                ),
                child: Row(
                  children: [
                    const AppSvg(
                      'assets/figma/explore/ic_streak_small.svg',
                      width: 9.33,
                      height: 11.08,
                    ),
                    SizedBox(width: 4.dsp),
                    Text(
                      Strings.streakShort.i18n.fill([streakDays]),
                      style: AppText.mono(
                        10,
                        height: 14,
                        color: AppPalette.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.dsp),
              SizedBox(
                width: 44.dsp,
                height: 44.dsp,
                child: const Center(child: DevAvatar()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class _Dot extends StatelessWidget {
  final double size;

  const _Dot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.dsp,
      height: size.dsp,
      decoration: const BoxDecoration(
        color: AppPalette.teal,
        shape: BoxShape.circle,
      ),
    );
  }
}

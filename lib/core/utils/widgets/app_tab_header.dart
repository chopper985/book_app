// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_avatar.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Header of the tab screens: the tab title with a contextual subtitle, the
/// streak and the learner's own avatar.
class AppTabHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final int streakDays;
  final String displayName;
  final String? avatarPath;

  /// Usually opens the Profile tab; `null` on the Profile tab itself.
  final VoidCallback? onAvatarTap;

  const AppTabHeader({
    super.key,
    required this.title,
    required this.streakDays,
    required this.displayName,
    this.subtitle,
    this.avatarPath,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.surfaceLowest.withValues(alpha: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 64.dsp),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.dsp, vertical: 8.dsp),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(
                          20,
                          height: 28,
                          weight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (subtitle case final text? when text.isNotEmpty)
                        Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.mono(
                            11,
                            height: 16,
                            weight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8.dsp),
                _StreakChip(days: streakDays),
                SizedBox(width: 8.dsp),
                Semantics(
                  button: onAvatarTap != null,
                  label: displayName,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onAvatarTap,
                    child: Padding(
                      padding: EdgeInsets.all(4.dsp),
                      child: AppAvatar(
                        path: avatarPath,
                        name: displayName,
                        size: 36,
                      ),
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

class _StreakChip extends StatelessWidget {
  final int days;

  const _StreakChip({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.dsp, vertical: 4.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceHigh,
        borderRadius: BorderRadius.circular(8.dsp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvg(
            Assets.figma.explore.icStreakSmall,
            width: 9.33,
            height: 11.08,
          ),
          SizedBox(width: 4.dsp),
          Text(
            Strings.profileStreakValue.i18n.fill([days]),
            style: AppText.mono(
              11,
              height: 16,
              color: days > 0 ? AppPalette.teal : AppPalette.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

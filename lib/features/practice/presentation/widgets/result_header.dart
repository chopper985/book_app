// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_progress_bar.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/core/utils/widgets/dev_header.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Report header: back, logo, title, level badge, avatar and the score strip.
class ResultHeader extends StatelessWidget {
  final VoidCallback onBack;

  /// Level badge label; hidden when null.
  final String? levelLabel;

  /// Fill of the top progress strip; hidden when null.
  final double? progress;

  const ResultHeader({
    super.key,
    required this.onBack,
    this.levelLabel,
    this.progress,
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
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 56.dsp),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.dsp),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      child: InkWell(
                        onTap: onBack,
                        customBorder: const CircleBorder(),
                        child: SizedBox.square(
                          dimension: 44.dsp,
                          child: Center(
                            child: AppSvg(
                              Assets.figma.result.back,
                              width: 13.33,
                              height: 13.33,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.dsp),
                    Image.asset(
                      'assets/images/figma/logo.jpg',
                      width: 44.03.dsp,
                      height: 24.dsp,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(width: 8.dsp),
                    Expanded(
                      child: Text(
                        Strings.resultTitle.i18n,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(
                          16,
                          height: 24,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (levelLabel != null) ...[
                      SizedBox(width: 8.dsp),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.dsp,
                          vertical: 2.dsp,
                        ),
                        decoration: BoxDecoration(
                          color: AppPalette.surfaceHigh,
                          borderRadius: BorderRadius.circular(8.dsp),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppSvg(
                              Assets.figma.result.levelBolt,
                              width: 9.33,
                              height: 11.67,
                            ),
                            SizedBox(width: 4.dsp),
                            Text(
                              levelLabel!,
                              style: AppText.mono(
                                10,
                                height: 14,
                                color: AppPalette.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(width: 8.dsp),
                    const DevAvatar(),
                  ],
                ),
              ),
            ),
            if (progress != null)
              AppProgressBar(
                value: progress!,
                height: 4,
                color: AppPalette.primaryStrong,
              ),
          ],
        ),
      ),
    );
  }
}

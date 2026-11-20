// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/dev_header.dart';

/// Top bar of the practice screen: back, logo, title, track pill, avatar.
class PracticeHeader extends StatelessWidget {
  final String pillLabel;
  final VoidCallback onBack;

  const PracticeHeader({
    super.key,
    required this.pillLabel,
    required this.onBack,
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
            padding: EdgeInsets.symmetric(horizontal: 8.dsp),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: Icon(
                    Icons.arrow_back,
                    size: 24.dsp,
                    color: AppPalette.onSurface,
                  ),
                ),
                SizedBox(width: 4.dsp),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.dsp),
                  child: Image.asset(
                    'assets/images/figma/logo.jpg',
                    width: 44.dsp,
                    height: 24.dsp,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(width: 12.dsp),
                Expanded(
                  child: Text(
                    Strings.practiceSessionTitle.i18n,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(
                      18,
                      height: 28,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 8.dsp),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.dsp,
                      vertical: 2.dsp,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.tealContainer,
                      border: Border.all(
                        color: AppPalette.teal.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12.dsp),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 12.dsp, color: AppPalette.teal),
                        SizedBox(width: 2.dsp),
                        Flexible(
                          child: Text(
                            pillLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.mono(
                              10,
                              height: 14,
                              color: AppPalette.teal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.dsp),
                const DevAvatar(),
                SizedBox(width: 8.dsp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

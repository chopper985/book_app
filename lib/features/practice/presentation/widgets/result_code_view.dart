// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Read-only code block (Code Snippet Container): line numbers, no wrapping,
/// horizontal scroll.
class ResultCodeView extends StatelessWidget {
  final CodeSnippet code;

  const ResultCodeView({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final lines = code.source.trimRight().split('\n');
    final numberStyle = AppText.mono(
      11,
      height: 16,
      weight: FontWeight.w400,
      color: AppPalette.onSurfaceVariant.withValues(alpha: 0.3),
    );
    final codeStyle = AppText.mono(11, height: 16, weight: FontWeight.w400);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.dsp),
      child: ColoredBox(
        color: AppPalette.surfaceLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppPalette.surfaceHigh,
              padding: EdgeInsets.symmetric(horizontal: 8.dsp, vertical: 9.dsp),
              child: Row(
                children: [
                  AppSvg(
                    Assets.figma.result.code,
                    width: 10,
                    height: 6,
                  ),
                  SizedBox(width: 6.dsp),
                  Expanded(
                    child: Text(
                      code.language,
                      style: AppText.mono(
                        10,
                        height: 14,
                        color: AppPalette.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    Strings.resultCodeLabel.i18n,
                    style: AppText.mono(10, height: 14),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(8.dsp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < lines.length; i++)
                        Text('${i + 1}', style: numberStyle),
                    ],
                  ),
                  SizedBox(width: 8.dsp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final line in lines)
                        Text(line, style: codeStyle, softWrap: false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

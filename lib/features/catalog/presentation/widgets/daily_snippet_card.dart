// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_learning.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';

/// "Micro Delighter: Daily Code Snippet Teaser".
class DailySnippetCard extends StatelessWidget {
  final DailySnippet snippet;
  final VoidCallback? onSolve;

  const DailySnippetCard({super.key, required this.snippet, this.onSolve});

  @override
  Widget build(BuildContext context) {
    final codeStyle = AppText.mono(
      12,
      height: 16,
      weight: FontWeight.w400,
      color: AppPalette.onSurface,
    );
    final commentStyle = codeStyle.copyWith(
      color: AppPalette.onSurfaceVariant.withValues(alpha: 0.5),
    );
    final lines = snippet.code.split('\n');

    return Container(
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(8.dsp),
        border: Border.all(color: AppPalette.surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.terminal,
                size: 12.dsp,
                color: AppPalette.primary,
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: Text(
                  Strings.trackSnippetTitle.i18n,
                  style: AppText.mono(
                    12,
                    height: 16,
                    weight: FontWeight.w700,
                    color: AppPalette.primary,
                  ),
                ),
              ),
              Text(
                Strings.trackSnippetReward.i18n.fill([snippet.rewardXp]),
                style: AppText.mono(11, height: 16, weight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8.dsp),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.dsp),
            decoration: BoxDecoration(
              color: AppPalette.surfaceLowest,
              borderRadius: BorderRadius.circular(6.dsp),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text.rich(
                TextSpan(
                  children: [
                    for (var i = 0; i < lines.length; i++)
                      TextSpan(
                        text:
                            i == lines.length - 1 ? lines[i] : '${lines[i]}\n',
                        style: lines[i].trimLeft().startsWith('//')
                            ? commentStyle
                            : codeStyle,
                      ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.dsp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4.dsp),
                  child: Text(
                    snippet.question.text,
                    style: AppText.sans(
                      12,
                      height: 18,
                      color: AppPalette.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.dsp),
              InkWell(
                onTap: onSolve,
                borderRadius: BorderRadius.circular(4.dsp),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.dsp,
                    vertical: 4.dsp,
                  ),
                  child: Text(
                    Strings.trackSnippetSolve.i18n,
                    style: AppText.sans(
                      12,
                      height: 18,
                      weight: FontWeight.w600,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';

/// Placeholder for tabs that are not built yet.
class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.dsp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppText.sans(20, weight: FontWeight.w600)),
                SizedBox(height: 8.dsp),
                Text(
                  '${Strings.comingSoon.i18n} · ${Strings.comingSoonMessage.i18n}',
                  textAlign: TextAlign.center,
                  style: AppText.sans(14, color: AppPalette.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

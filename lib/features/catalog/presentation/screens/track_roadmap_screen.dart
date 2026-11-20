// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_detail_view.dart';

/// One track of a position roadmap, full screen with a back link.
class TrackRoadmapScreen extends StatelessWidget {
  const TrackRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.surface,
      body: SafeArea(
        child: TrackDetailView(
          top: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                size: 16.dsp,
                color: AppPalette.onSurfaceVariant,
              ),
              label: Text(
                Strings.trackBackToPosition.i18n,
                style: AppText.mono(12, height: 16, weight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

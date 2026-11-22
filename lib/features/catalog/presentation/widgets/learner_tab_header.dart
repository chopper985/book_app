// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/widgets/app_tab_header.dart';
import 'package:interview_practice/features/catalog/domain/entities/explore_dashboard.dart';

/// [AppTabHeader] filled from the learner: streak and avatar. Tapping the
/// avatar opens the Profile tab, except on the Profile tab itself.
class LearnerTabHeader extends StatelessWidget {
  final LearnerSummary learner;
  final String title;
  final String? subtitle;
  final bool isProfileTab;

  const LearnerTabHeader({
    super.key,
    required this.learner,
    required this.title,
    this.subtitle,
    this.isProfileTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppTabHeader(
      title: title,
      subtitle: subtitle,
      streakDays: learner.streakDays,
      displayName: learner.displayName,
      avatarPath: learner.avatarPath,
      onAvatarTap: isProfileTab ? null : () => const ProfileRoute().go(context),
    );
  }
}

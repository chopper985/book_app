// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/premium/domain/entities/practice_quota.dart';
import 'package:interview_practice/features/premium/presentation/cubit/quota_cubit.dart';
import 'package:interview_practice/features/premium/presentation/extensions/purchase_failure_message.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_sections.dart';

/// Plan, sessions left today and extra sessions, in the Profile tab.
class PlanSection extends StatelessWidget {
  const PlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuotaCubit, PracticeQuota>(
      builder: (context, quota) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionTitle(Strings.planTitle.i18n),
          ProfilePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      quota.isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.bolt_rounded,
                      size: 20.dsp,
                      color: quota.isPremium
                          ? AppPalette.purpleDeep
                          : AppPalette.primary,
                    ),
                    SizedBox(width: 8.dsp),
                    Expanded(
                      child: Text(
                        quota.isPremium
                            ? Strings.planPremium.i18n
                            : Strings.planFree.i18n,
                        style: AppText.sans(
                          15,
                          height: 22,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (quota.isPremium && quota.premiumExpiresAt != null) ...[
                  SizedBox(height: 2.dsp),
                  Text(
                    Strings.premiumActiveUntil.i18n
                        .fill([formatPlanDate(quota.premiumExpiresAt!)]),
                    style: AppText.sans(
                      12,
                      height: 18,
                      color: AppPalette.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: 12.dsp),
                Text(
                  Strings.planToday.i18n
                      .fill([quota.remainingToday, quota.dailyLimit]),
                  style: AppText.sans(13, height: 18),
                ),
                SizedBox(height: 6.dsp),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: quota.dailyLimit == 0
                        ? 0
                        : quota.remainingToday / quota.dailyLimit,
                    minHeight: 6.dsp,
                    color: AppPalette.primaryStrong,
                    backgroundColor: AppPalette.surfaceHigh,
                  ),
                ),
                if (quota.extraSessions > 0) ...[
                  SizedBox(height: 8.dsp),
                  Text(
                    Strings.planExtra.i18n.fill([quota.extraSessions]),
                    style: AppText.sans(
                      12,
                      height: 18,
                      color: AppPalette.onSurfaceVariant,
                    ),
                  ),
                ],
                SizedBox(height: 12.dsp),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.primary,
                      side: const BorderSide(color: AppPalette.primaryStrong),
                      minimumSize: Size.fromHeight(44.dsp),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.dsp),
                      ),
                    ),
                    onPressed: () => const PaywallRoute().push<bool>(context),
                    child: Text(
                      quota.isPremium
                          ? Strings.planBuyMore.i18n
                          : Strings.planUpgrade.i18n,
                      style: AppText.sans(
                        14,
                        weight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

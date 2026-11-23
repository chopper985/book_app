// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/premium/domain/entities/practice_quota.dart';
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';

/// One selectable store package on the paywall.
class PackageCard extends StatelessWidget {
  final StorePackage package;
  final bool selected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (title, period, hint) = switch (package.kind) {
      StorePackageKind.monthly => (
          Strings.premiumMonthly.i18n,
          Strings.premiumPerMonth.i18n,
          Strings.premiumSubscriptionHint.i18n
              .fill([PremiumPlans.premiumDailySessions]),
        ),
      StorePackageKind.annual => (
          Strings.premiumAnnual.i18n,
          Strings.premiumPerYear.i18n,
          Strings.premiumSubscriptionHint.i18n
              .fill([PremiumPlans.premiumDailySessions]),
        ),
      StorePackageKind.sessions => (
          Strings.premiumSessionsPack.i18n.fill([package.sessions]),
          '',
          Strings.premiumSessionsPackHint.i18n,
        ),
    };
    final radius = BorderRadius.circular(14.dsp);
    return Material(
      color:
          selected ? AppPalette.primaryContainer : AppPalette.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.dsp),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 22.dsp,
                color: selected
                    ? AppPalette.primaryStrong
                    : AppPalette.onSurfaceVariant,
              ),
              SizedBox(width: 12.dsp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.dsp,
                      runSpacing: 4.dsp,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppText.sans(
                            16,
                            height: 22,
                            weight: FontWeight.w600,
                          ),
                        ),
                        if (package.kind == StorePackageKind.annual)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.dsp,
                              vertical: 2.dsp,
                            ),
                            decoration: BoxDecoration(
                              color: AppPalette.tealContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              Strings.premiumAnnualBadge.i18n,
                              style: AppText.mono(
                                10,
                                height: 14,
                                color: AppPalette.teal,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.dsp),
                    Text(
                      hint,
                      style: AppText.sans(
                        12,
                        height: 18,
                        color: AppPalette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.dsp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    package.price,
                    style:
                        AppText.sans(16, height: 22, weight: FontWeight.w700),
                  ),
                  if (period.isNotEmpty)
                    Text(
                      period,
                      style: AppText.sans(
                        12,
                        height: 16,
                        color: AppPalette.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

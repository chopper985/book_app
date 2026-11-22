// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:interview_practice/features/premium/domain/entities/practice_quota.dart';
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';
import 'package:interview_practice/features/premium/presentation/cubit/paywall_cubit.dart';
import 'package:interview_practice/features/premium/presentation/cubit/quota_cubit.dart';
import 'package:interview_practice/features/premium/presentation/extensions/purchase_failure_message.dart';
import 'package:interview_practice/features/premium/presentation/widgets/package_card.dart';

/// Premium plans and extra-session packs. Guests sign in first so the
/// purchase is saved to an account.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaywallCubit, PaywallState>(
      listenWhen: (previous, current) =>
          (current.notice != null && previous.notice != current.notice) ||
          (current.failure != null && previous.failure != current.failure),
      listener: (context, state) {
        final message = switch (state.notice) {
          PaywallNotice.purchased => Strings.premiumPurchased.i18n,
          PaywallNotice.sessionsAdded =>
            Strings.premiumSessionsAdded.i18n.fill([state.addedSessions]),
          PaywallNotice.restored => Strings.premiumRestored.i18n,
          PaywallNotice.nothingToRestore =>
            Strings.premiumNothingToRestore.i18n,
          null => state.failure?.message,
        };
        if (message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
        if (state.notice == PaywallNotice.purchased ||
            state.notice == PaywallNotice.sessionsAdded) {
          context.pop(true);
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppPalette.surfaceLowest,
        appBar: AppBar(
          backgroundColor: AppPalette.surfaceLowest,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => context.pop(false),
            icon: Icon(Icons.close, size: 22.dsp, color: AppPalette.onSurface),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.dsp, 0, 20.dsp, 16.dsp),
                  children: [
                    const _Header(),
                    SizedBox(height: 20.dsp),
                    const _Benefits(),
                    SizedBox(height: 24.dsp),
                    if (state.loading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.dsp),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppPalette.primary,
                          ),
                        ),
                      )
                    else if (!state.configured)
                      _Note(Strings.premiumNotReady.i18n)
                    else
                      for (final package in state.packages) ...[
                        PackageCard(
                          package: package,
                          selected: package.id == state.selectedId,
                          onTap: () =>
                              context.read<PaywallCubit>().select(package.id),
                        ),
                        SizedBox(height: 12.dsp),
                      ],
                  ],
                ),
              ),
              _Footer(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final quota = context.watch<QuotaCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56.dsp,
          height: 56.dsp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.dsp),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppPalette.purpleDeep, AppPalette.primaryStrong],
            ),
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            size: 30.dsp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.dsp),
        Text(
          Strings.premiumTitle.i18n,
          style: AppText.sans(26, height: 34, weight: FontWeight.w700),
        ),
        SizedBox(height: 6.dsp),
        Text(
          quota.isPremium
              ? (quota.premiumExpiresAt == null
                  ? Strings.premiumActive.i18n
                  : Strings.premiumActiveUntil.i18n
                      .fill([formatPlanDate(quota.premiumExpiresAt!)]))
              : Strings.premiumSubtitle.i18n,
          style: AppText.sans(
            15,
            height: 22,
            color:
                quota.isPremium ? AppPalette.teal : AppPalette.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    final benefits = [
      Strings.premiumBenefitDaily.i18n.fill([
        PremiumPlans.premiumDailySessions,
        PremiumPlans.freeDailySessions,
      ]),
      Strings.premiumBenefitLevels.i18n,
      Strings.premiumBenefitAds.i18n,
    ];
    return Column(
      children: [
        for (final benefit in benefits)
          Padding(
            padding: EdgeInsets.only(bottom: 10.dsp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 20.dsp,
                  color: AppPalette.teal,
                ),
                SizedBox(width: 10.dsp),
                Expanded(
                  child: Text(
                    benefit,
                    style: AppText.sans(14, height: 20),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  final String text;

  const _Note(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(12.dsp),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppText.sans(14, height: 20, color: AppPalette.onSurfaceVariant),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final PaywallState state;

  const _Footer({required this.state});

  Future<void> _buy(BuildContext context) async {
    final cubit = context.read<PaywallCubit>();
    final linked = context.read<AuthCubit>().state.isLinked;
    if (!linked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.premiumSignInFirst.i18n)),
      );
      final signedIn = await const SignInRoute().push<bool>(context);
      if (!(signedIn ?? false)) return;
    }
    await cubit.purchase();
  }

  @override
  Widget build(BuildContext context) {
    final canBuy = state.configured && state.selected != null && !state.busy;
    final cubit = context.read<PaywallCubit>();
    return Container(
      padding: EdgeInsets.fromLTRB(20.dsp, 12.dsp, 20.dsp, 12.dsp),
      decoration: const BoxDecoration(
        color: AppPalette.surface,
        border: Border(top: BorderSide(color: AppPalette.surfaceHigh)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.primaryStrong,
              foregroundColor: AppPalette.onPrimaryStrong,
              disabledBackgroundColor: AppPalette.surfaceHigh,
              minimumSize: Size.fromHeight(50.dsp),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.dsp),
              ),
            ),
            onPressed: canBuy ? () => _buy(context) : null,
            child: state.busy
                ? SizedBox.square(
                    dimension: 20.dsp,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppPalette.onSurfaceVariant,
                    ),
                  )
                : Text(
                    Strings.premiumContinue.i18n,
                    style: AppText.sans(
                      15,
                      weight: FontWeight.w600,
                      color: canBuy
                          ? AppPalette.onPrimaryStrong
                          : AppPalette.onSurfaceVariant,
                    ),
                  ),
          ),
          TextButton(
            onPressed: state.configured && !state.busy ? cubit.restore : null,
            child: Text(
              Strings.premiumRestore.i18n,
              style: AppText.sans(
                13,
                weight: FontWeight.w600,
                color: AppPalette.onSurfaceVariant,
              ),
            ),
          ),
          if (state.selected?.kind != StorePackageKind.sessions)
            Text(
              Strings.premiumRenewNote.i18n,
              textAlign: TextAlign.center,
              style: AppText.sans(
                11,
                height: 16,
                color: AppPalette.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

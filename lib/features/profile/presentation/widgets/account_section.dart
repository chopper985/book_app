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
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:interview_practice/features/auth/presentation/extensions/auth_failure_message.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_sections.dart';

/// Account status in the Profile tab: sign in as a guest, or the linked
/// account with sign-out and account deletion.
class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSectionTitle(Strings.accountTitle.i18n),
            if (user != null && user.isLinked)
              _LinkedAccount(user: user, busy: state.busy)
            else
              const _Guest(),
          ],
        );
      },
    );
  }
}

class _Guest extends StatelessWidget {
  const _Guest();

  @override
  Widget build(BuildContext context) {
    return ProfilePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 20.dsp,
                color: AppPalette.onSurfaceVariant,
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: Text(
                  Strings.accountGuest.i18n,
                  style: AppText.sans(15, height: 22, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.dsp),
          Text(
            Strings.accountGuestHint.i18n,
            style: AppText.sans(
              13,
              height: 18,
              color: AppPalette.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.dsp),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.primaryStrong,
                foregroundColor: AppPalette.onPrimaryStrong,
                minimumSize: Size.fromHeight(44.dsp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.dsp),
                ),
              ),
              onPressed: () => const SignInRoute().push<bool>(context),
              child: Text(
                Strings.accountSignIn.i18n,
                style: AppText.sans(
                  14,
                  weight: FontWeight.w600,
                  color: AppPalette.onPrimaryStrong,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedAccount extends StatelessWidget {
  final AuthUser user;
  final bool busy;

  const _LinkedAccount({required this.user, required this.busy});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surfaceContainer,
        title: Text(
          title,
          style: AppText.sans(18, height: 26, weight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: AppText.sans(
            14,
            height: 20,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              Strings.accountCancel.i18n,
              style: AppText.sans(14, weight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirm,
              style: AppText.sans(
                14,
                weight: FontWeight.w600,
                color: AppPalette.error,
              ),
            ),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _signOut(BuildContext context) async {
    final cubit = context.read<AuthCubit>();
    final ok = await _confirm(
      context,
      title: Strings.accountSignOutTitle.i18n,
      message: Strings.accountSignOutMessage.i18n,
      confirm: Strings.accountSignOut.i18n,
    );
    if (ok) await cubit.signOut();
  }

  Future<void> _delete(BuildContext context) async {
    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _confirm(
      context,
      title: Strings.accountDeleteTitle.i18n,
      message: Strings.accountDeleteMessage.i18n,
      confirm: Strings.accountDelete.i18n,
    );
    if (!ok) return;
    final failure = await cubit.deleteAccount();
    messenger.showSnackBar(
      SnackBar(
        content: Text(failure?.message ?? Strings.accountDeleted.i18n),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final identifier = user.identifier ?? user.displayName ?? '';
    return ProfilePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                user.providers.contains(AuthProviderKind.google)
                    ? Icons.account_circle_outlined
                    : Icons.phone_iphone,
                size: 20.dsp,
                color: AppPalette.teal,
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: Text(
                  Strings.accountSignedInWith.i18n.fill([identifier]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(14, height: 20, weight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.dsp),
          Row(
            children: [
              Icon(
                Icons.cloud_done_outlined,
                size: 14.dsp,
                color: AppPalette.teal,
              ),
              SizedBox(width: 6.dsp),
              Expanded(
                child: Text(
                  Strings.accountSynced.i18n,
                  style: AppText.sans(12, height: 16, color: AppPalette.teal),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.dsp),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _signOut(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(44.dsp),
                    side: const BorderSide(color: AppPalette.surfaceHigh),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.dsp),
                    ),
                  ),
                  child: busy
                      ? SizedBox.square(
                          dimension: 18.dsp,
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          Strings.accountSignOut.i18n,
                          style: AppText.sans(14, weight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.dsp),
          Center(
            child: TextButton(
              onPressed: busy ? null : () => _delete(context),
              child: Text(
                Strings.accountDelete.i18n,
                style: AppText.sans(
                  13,
                  weight: FontWeight.w600,
                  color: AppPalette.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:interview_practice/features/auth/presentation/extensions/auth_failure_message.dart';
import 'package:interview_practice/features/auth/presentation/widgets/auth_button.dart';

/// Choose how to sign in. Pops `true` once signed in.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignInCubit>();
    return BlocConsumer<SignInCubit, SignInState>(
      listenWhen: (previous, current) =>
          (!previous.done && current.done) ||
          (current.failure != null && previous.failure != current.failure),
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.done) {
          messenger.showSnackBar(
            SnackBar(content: Text(Strings.authSuccess.i18n)),
          );
          context.pop(true);
        } else if (state.failure case final failure?) {
          messenger.showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: AppPalette.surface,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 16.dsp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => context.pop(false),
                    icon: Icon(
                      Icons.close,
                      size: 22.dsp,
                      color: AppPalette.onSurface,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.cloud_sync_outlined,
                  size: 56.dsp,
                  color: AppPalette.primary,
                ),
                SizedBox(height: 16.dsp),
                Text(
                  Strings.authTitle.i18n,
                  textAlign: TextAlign.center,
                  style: AppText.sans(
                    26,
                    height: 34,
                    weight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 8.dsp),
                Text(
                  Strings.authSubtitle.i18n,
                  textAlign: TextAlign.center,
                  style: AppText.sans(
                    15,
                    height: 22,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                AuthButton(
                  label: Strings.authGoogle.i18n,
                  filled: false,
                  loading: state.busy,
                  icon: const _GoogleMark(),
                  onTap: cubit.signInWithGoogle,
                ),
                SizedBox(height: 12.dsp),
                AuthButton(
                  label: Strings.authPhone.i18n,
                  icon: Icon(
                    Icons.phone_iphone,
                    size: 20.dsp,
                    color: AppPalette.onPrimaryStrong,
                  ),
                  onTap: state.busy
                      ? null
                      : () async {
                          final signedIn = await const PhoneSignInRoute()
                              .push<bool>(context);
                          if ((signedIn ?? false) && context.mounted) {
                            context.pop(true);
                          }
                        },
                ),
                SizedBox(height: 16.dsp),
                Text(
                  Strings.authKeepData.i18n,
                  textAlign: TextAlign.center,
                  style: AppText.sans(
                    12,
                    height: 18,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(
                    Strings.authSkip.i18n,
                    style: AppText.sans(
                      14,
                      weight: FontWeight.w600,
                      color: AppPalette.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Neutral "G" badge (the official logo asset is not bundled yet).
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.dsp,
      height: 22.dsp,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Text(
        'G',
        style: AppText.sans(
          14,
          height: 18,
          weight: FontWeight.w700,
          color: const Color(0xFF4285F4),
        ),
      ),
    );
  }
}

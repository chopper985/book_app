// Flutter imports:
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:interview_practice/features/auth/presentation/extensions/auth_failure_message.dart';
import 'package:interview_practice/features/auth/presentation/widgets/auth_button.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_form_fields.dart';

/// Phone number, then the 6-digit SMS code. Pops `true` once signed in.
class PhoneSignInScreen extends StatelessWidget {
  const PhoneSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignInCubit>();
    return BlocConsumer<SignInCubit, SignInState>(
      listenWhen: (previous, current) => !previous.done && current.done,
      listener: (context, _) => context.pop(true),
      builder: (context, state) => PopScope(
        canPop: state.step == SignInStep.phone,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) cubit.editPhone();
        },
        child: Scaffold(
          backgroundColor: AppPalette.surface,
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 24.dsp),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => state.step == SignInStep.code
                        ? cubit.editPhone()
                        : context.pop(false),
                    icon: Icon(
                      Icons.arrow_back,
                      size: 20.dsp,
                      color: AppPalette.onSurface,
                    ),
                  ),
                ),
                SizedBox(height: 8.dsp),
                if (state.step == SignInStep.phone)
                  _PhoneStep(state: state)
                else
                  _CodeStep(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Heading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppText.sans(
            24,
            height: 32,
            weight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 4.dsp),
        Text(
          subtitle,
          style: AppText.sans(
            14,
            height: 20,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 24.dsp),
      ],
    );
  }
}

class _PhoneStep extends StatelessWidget {
  final SignInState state;

  const _PhoneStep({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignInCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(
          title: Strings.authPhoneTitle.i18n,
          subtitle: Strings.authPhoneSubtitle.i18n,
        ),
        ProfileTextField(
          initial: state.phone,
          hint: Strings.authPhoneHint.i18n,
          autofocus: true,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9+ ]')),
            LengthLimitingTextInputFormatter(16),
          ],
          errorText: state.failure?.message,
          textInputAction: TextInputAction.done,
          onChanged: cubit.setPhone,
          onSubmitted: cubit.sendCode,
        ),
        SizedBox(height: 16.dsp),
        AuthButton(
          label: Strings.authSendCode.i18n,
          loading: state.busy,
          onTap: state.canSendCode ? cubit.sendCode : null,
        ),
      ],
    );
  }
}

class _CodeStep extends StatelessWidget {
  final SignInState state;

  const _CodeStep({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignInCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(
          title: Strings.authCodeTitle.i18n,
          subtitle: Strings.authCodeSubtitle.i18n.fill([state.phone.trim()]),
        ),
        ProfileTextField(
          key: ValueKey(state.verificationId),
          initial: '',
          hint: '••••••',
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          errorText: state.failure?.message,
          textInputAction: TextInputAction.done,
          onChanged: cubit.setCode,
          onSubmitted: cubit.confirmCode,
        ),
        SizedBox(height: 16.dsp),
        AuthButton(
          label: Strings.authConfirm.i18n,
          loading: state.busy,
          onTap: state.canConfirm ? cubit.confirmCode : null,
        ),
        SizedBox(height: 8.dsp),
        // Wraps onto two lines on narrow screens or large text.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: cubit.editPhone,
              child: Text(
                Strings.authChangePhone.i18n,
                style: AppText.sans(13, color: AppPalette.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: state.canResend ? cubit.resendCode : null,
              child: Text(
                state.resendSeconds > 0
                    ? Strings.authResendIn.i18n.fill([state.resendSeconds])
                    : Strings.authResend.i18n,
                style: AppText.sans(
                  13,
                  weight: FontWeight.w600,
                  color: state.canResend
                      ? AppPalette.primary
                      : AppPalette.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:interview_practice/features/auth/presentation/extensions/auth_failure_message.dart';
import 'package:interview_practice/gen/assets.gen.dart';
import 'package:interview_practice/features/auth/presentation/widgets/guest_data_dialog.dart';

/// Welcome / sign-in screen (Figma 343:1356), opened from "Sign in".
/// Pops `true` once signed in, `false` when the learner stays a guest.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignInCubit>();
    return GuestDataListener(
      child: BlocConsumer<SignInCubit, SignInState>(
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
          backgroundColor: AppPalette.surfaceLowest,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.dsp),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 3),
                        const _Brand(),
                        const Spacer(flex: 2),
                        _ProviderButton(
                          label: Strings.authGoogle.i18n,
                          background: Colors.white,
                          foreground: const Color(0xFF1F1F1F),
                          leading: AppSvg(
                            Assets.figma.auth.icGoogle,
                            width: 20,
                            height: 20,
                          ),
                          loading: state.busy,
                          onTap: cubit.signInWithGoogle,
                        ),
                        SizedBox(height: 12.dsp),
                        _ProviderButton(
                          label: Strings.authFacebook.i18n,
                          background: const Color(0xFF1A2540),
                          foreground: Colors.white,
                          border: const Color(0xFF26355C),
                          leading: AppSvg(
                            Assets.figma.auth.icFacebook,
                            width: 20,
                            height: 20,
                          ),
                          onTap: state.busy ? null : cubit.signInWithFacebook,
                        ),
                        SizedBox(height: 12.dsp),
                        _ProviderButton(
                          label: Strings.authPhone.i18n,
                          background: AppPalette.surfaceLow,
                          foreground: AppPalette.onSurface,
                          border: AppPalette.surfaceHigh,
                          leading: Container(
                            width: 28.dsp,
                            height: 28.dsp,
                            decoration: BoxDecoration(
                              color: AppPalette.surfaceHigh,
                              borderRadius: BorderRadius.circular(6.dsp),
                            ),
                            child: Icon(
                              Icons.phone_iphone,
                              size: 16.dsp,
                              color: AppPalette.primary,
                            ),
                          ),
                          onTap: state.busy
                              ? null
                              : () async {
                                  final signedIn =
                                      await const PhoneSignInRoute()
                                          .push<bool>(context);
                                  if ((signedIn ?? false) && context.mounted) {
                                    context.pop(true);
                                  }
                                },
                        ),
                        SizedBox(height: 8.dsp),
                        TextButton.icon(
                          onPressed: () => context.pop(false),
                          icon: Icon(
                            Icons.person_outline,
                            size: 18.dsp,
                            color: AppPalette.onSurfaceVariant,
                          ),
                          label: Text(
                            Strings.authGuest.i18n,
                            textAlign: TextAlign.center,
                            style: AppText.sans(
                              14,
                              height: 20,
                              weight: FontWeight.w600,
                              color: AppPalette.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const _Terms(),
                        SizedBox(height: 16.dsp),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88.dsp,
          height: 88.dsp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.dsp),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppPalette.primaryStrong, AppPalette.teal],
            ),
            boxShadow: [
              BoxShadow(
                color: AppPalette.primaryStrong.withValues(alpha: 0.45),
                blurRadius: 40.dsp,
                spreadRadius: 4.dsp,
              ),
            ],
          ),
          child: Icon(
            Icons.terminal_rounded,
            size: 44.dsp,
            color: AppPalette.onPrimaryStrong,
          ),
        ),
        SizedBox(height: 28.dsp),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.dsp, vertical: 6.dsp),
          decoration: BoxDecoration(
            color: AppPalette.primaryContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppPalette.primaryStrong.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            Strings.authBadge.i18n,
            style: AppText.mono(
              11,
              height: 16,
              color: AppPalette.primary,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(height: 16.dsp),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: Strings.authBrandFirst.i18n),
              TextSpan(
                text: Strings.authBrandSecond.i18n,
                style: const TextStyle(color: AppPalette.primaryStrong),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppText.sans(
            34,
            height: 42,
            weight: FontWeight.w700,
            letterSpacing: -0.8,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10.dsp),
        Text(
          Strings.authSubtitle.i18n,
          textAlign: TextAlign.center,
          style: AppText.sans(
            15,
            height: 22,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final Color background;
  final Color foreground;
  final Color? border;
  final bool loading;
  final VoidCallback? onTap;

  const _ProviderButton({
    required this.label,
    required this.leading,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.border,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.dsp);
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: onTap == null && !loading ? 0.6 : 1,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border == null ? BorderSide.none : BorderSide(color: border!),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 54.dsp),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.dsp, vertical: 8.dsp),
              child: Center(
                child: loading
                    ? SizedBox.square(
                        dimension: 20.dsp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          leading,
                          SizedBox(width: 12.dsp),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.sans(
                                15,
                                height: 22,
                                weight: FontWeight.w600,
                                color: foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Terms extends StatelessWidget {
  const _Terms();

  @override
  Widget build(BuildContext context) {
    const link = TextStyle(
      color: AppPalette.primary,
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: Strings.authTermsPrefix.i18n),
          TextSpan(text: Strings.authTerms.i18n, style: link),
          TextSpan(text: Strings.authTermsJoin.i18n),
          TextSpan(text: Strings.authPrivacy.i18n, style: link),
        ],
      ),
      textAlign: TextAlign.center,
      style: AppText.sans(
        12,
        height: 18,
        color: AppPalette.onSurfaceVariant,
      ),
    );
  }
}

// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';

/// Listens for [SignInState.guestSessions] and asks whether the guest
/// progress on this device joins the account the learner signed in to.
class GuestDataListener extends StatelessWidget {
  final Widget child;

  const GuestDataListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInCubit, SignInState>(
      listenWhen: (previous, current) =>
          current.guestSessions != null &&
          previous.guestSessions != current.guestSessions,
      listener: (context, state) async {
        final cubit = context.read<SignInCubit>();
        final keep = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              _GuestDataDialog(sessions: state.guestSessions!),
        );
        await cubit.resolveGuestData(keepGuestProgress: keep ?? true);
      },
      child: child,
    );
  }
}

class _GuestDataDialog extends StatelessWidget {
  final int sessions;

  const _GuestDataDialog({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: AppPalette.surfaceContainer,
        title: Text(
          Strings.guestDataTitle.i18n,
          style: AppText.sans(18, height: 26, weight: FontWeight.w600),
        ),
        content: Text(
          Strings.guestDataMessage.i18n.fill([sessions]),
          style: AppText.sans(
            14,
            height: 20,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        actionsOverflowButtonSpacing: 4,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              Strings.guestDataDiscard.i18n,
              style: AppText.sans(
                14,
                weight: FontWeight.w600,
                color: AppPalette.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Strings.guestDataMerge.i18n,
              style: AppText.sans(
                14,
                weight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

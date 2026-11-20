// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/languages/service/model.dart';
import 'package:interview_practice/core/app/languages/service/service.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/dev_header.dart';
import 'package:interview_practice/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:interview_practice/features/profile/presentation/extensions/profile_labels.dart';
import 'package:interview_practice/features/profile/presentation/widgets/choice_tile.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_sections.dart';

/// Profile tab: profile card, statistics, roadmaps and settings.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => switch (state) {
          ProfileLoading() => const Center(
              child: CircularProgressIndicator(color: AppPalette.primary),
            ),
          ProfileLoaded() => _Body(state: state),
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ProfileLoaded state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    return Column(
      children: [
        DevHeader(
          roleLabel: state.learner.experience.headerLabel,
          streakDays: state.learner.streakDays,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.dsp, 16.dsp, 16.dsp, 24.dsp),
            children: [
              Text(
                Strings.profileTitle.i18n,
                style: AppText.sans(
                  24,
                  height: 32,
                  weight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 16.dsp),
              if (profile != null) ...[
                ProfileCard(
                  profile: profile,
                  avatarPath: state.avatarPath,
                  stack: state.stack,
                  onEdit: () => const EditProfileRoute().push<void>(context),
                ),
                SizedBox(height: 24.dsp),
              ],
              ProfileSectionTitle(Strings.profileStatsTitle.i18n),
              ProfileStats(learner: state.learner),
              SizedBox(height: 24.dsp),
              ProfileSectionTitle(Strings.profileSettingsTitle.i18n),
              const _LanguageSetting(),
              SizedBox(height: 16.dsp),
              const _ResetProgressTile(),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageSetting extends StatelessWidget {
  const _LanguageSetting();

  @override
  Widget build(BuildContext context) {
    final current = I18n.locale.languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Strings.profileLanguage.i18n,
          style: AppText.mono(11, height: 16),
        ),
        SizedBox(height: 8.dsp),
        for (final language in Language.values) ...[
          ChoiceTile(
            title: language.base,
            selected: current == language.langCode,
            onTap: () {
              if (current == language.langCode) return;
              LanguageService().saveLocale(language.langCode);
              I18n.of(context).locale = language.locale;
              context.read<ProfileCubit>().languageChanged(language.langCode);
            },
          ),
          SizedBox(height: 8.dsp),
        ],
      ],
    );
  }
}

class _ResetProgressTile extends StatelessWidget {
  const _ResetProgressTile();

  Future<void> _confirm(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surfaceContainer,
        title: Text(
          Strings.profileResetTitle.i18n,
          style: AppText.sans(18, height: 26, weight: FontWeight.w600),
        ),
        content: Text(
          Strings.profileResetMessage.i18n,
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
              Strings.profileResetCancel.i18n,
              style: AppText.sans(14, weight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Strings.profileResetConfirm.i18n,
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
    if (confirmed != true) return;
    await cubit.resetProgress();
    messenger.showSnackBar(
      SnackBar(content: Text(Strings.profileResetDone.i18n)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Material(
      color: AppPalette.surfaceLow,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppPalette.error.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => _confirm(context),
        child: Padding(
          padding: EdgeInsets.all(16.dsp),
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 20.dsp,
                color: AppPalette.error,
              ),
              SizedBox(width: 12.dsp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.profileReset.i18n,
                      style: AppText.sans(
                        15,
                        height: 22,
                        weight: FontWeight.w600,
                        color: AppPalette.error,
                      ),
                    ),
                    SizedBox(height: 2.dsp),
                    Text(
                      Strings.profileResetHint.i18n,
                      style: AppText.sans(
                        12,
                        height: 16,
                        color: AppPalette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

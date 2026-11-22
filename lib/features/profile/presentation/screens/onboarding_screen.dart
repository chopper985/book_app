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
import 'package:interview_practice/core/utils/widgets/app_progress_bar.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/presentation/cubit/onboarding_cubit.dart';
import 'package:interview_practice/features/profile/presentation/extensions/profile_labels.dart';
import 'package:interview_practice/features/profile/presentation/widgets/choice_tile.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_form_fields.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => !previous.done && current.done,
      listener: (context, _) => const RootRoute().go(context),
      builder: (context, state) {
        return PopScope(
          canPop: state.step.index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.back();
          },
          child: Scaffold(
            backgroundColor: AppPalette.surface,
            body: SafeArea(
              child: Column(
                children: [
                  _Header(state: state, onBack: cubit.back),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: KeyedSubtree(
                        key: ValueKey(state.step),
                        child: _StepBody(state: state),
                      ),
                    ),
                  ),
                  _PrimaryButton(
                    label: (state.isLastStep
                            ? Strings.onboardingFinish
                            : Strings.onboardingNext)
                        .i18n,
                    loading: state.saving,
                    onTap: state.canContinue ? cubit.next : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final OnboardingState state;
  final VoidCallback onBack;

  const _Header({required this.state, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final showBack = state.step.index > 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(4.dsp, 8.dsp, 16.dsp, 8.dsp),
      child: Row(
        children: [
          SizedBox(
            width: 48.dsp,
            height: 48.dsp,
            child: showBack
                ? IconButton(
                    tooltip: Strings.onboardingBack.i18n,
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      size: 20.dsp,
                      color: AppPalette.onSurface,
                    ),
                  )
                : null,
          ),
          Expanded(
            child: AppProgressBar(
              value: state.stepNumber / state.stepCount,
              gradient: AppPalette.progressGradient,
            ),
          ),
          SizedBox(width: 12.dsp),
          Text(
            Strings.onboardingStep.i18n
                .fill([state.stepNumber, state.stepCount]),
            style: AppText.mono(11, height: 16),
          ),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  final OnboardingState state;

  const _StepBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return switch (state.step) {
      OnboardingStep.name => _StepLayout(
          title: Strings.onboardingNameTitle.i18n,
          subtitle: Strings.onboardingNameSubtitle.i18n,
          children: [
            _NameField(
              initial: state.name,
              onChanged: cubit.setName,
              onSubmitted: cubit.next,
            ),
            // New device: signing in restores the profile, and the router
            // then leaves onboarding by itself.
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => const SignInRoute().push<bool>(context),
                child: Text(
                  Strings.authHaveAccount.i18n,
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
      OnboardingStep.role => _StepLayout(
          title: Strings.onboardingRoleTitle.i18n,
          children: [
            for (final role in TargetRole.values)
              ChoiceTile(
                title: role.label,
                selected: state.role == role,
                onTap: () => cubit.selectRole(role),
              ),
          ],
        ),
      OnboardingStep.experience => _StepLayout(
          title: Strings.onboardingExperienceTitle.i18n,
          subtitle: Strings.onboardingExperienceSubtitle.i18n,
          children: [
            for (final experience in ExperienceLevel.values)
              ChoiceTile(
                title: experience.label,
                hint: experience.hint,
                selected: state.experience == experience,
                onTap: () => cubit.selectExperience(experience),
              ),
          ],
        ),
      OnboardingStep.stack => _StepLayout(
          title: Strings.onboardingStackTitle.i18n,
          subtitle: Strings.onboardingStackSubtitle.i18n,
          children: [
            for (final overview in state.tracks)
              _TrackTile(
                overview: overview,
                selected: state.techStack.contains(overview.track.id),
                onTap: () => cubit.toggleTrack(overview.track.id),
              ),
            SizedBox(height: 8.dsp),
            _InterviewDateField(
              date: state.interviewDate,
              onChanged: cubit.setInterviewDate,
            ),
          ],
        ),
    };
  }
}

class _StepLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _StepLayout({
    required this.title,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.dsp, 16.dsp, 16.dsp, 24.dsp),
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
        if (subtitle != null) ...[
          SizedBox(height: 4.dsp),
          Text(
            subtitle!,
            style: AppText.sans(
              14,
              height: 20,
              color: AppPalette.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: 24.dsp),
        for (final child in children) ...[
          child,
          SizedBox(height: 8.dsp),
        ],
      ],
    );
  }
}

/// Owns its controller so typing does not rebuild the whole step.
class _NameField extends StatefulWidget {
  final String initial;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  const _NameField({
    required this.initial,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.dsp),
      borderSide: const BorderSide(color: AppPalette.surfaceHigh),
    );
    return TextField(
      controller: _controller,
      autofocus: true,
      maxLength: LearnerProfile.maxNameLength,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: AppText.sans(16, height: 24),
      cursorColor: AppPalette.primary,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSubmitted(),
      decoration: InputDecoration(
        hintText: Strings.onboardingNameHint.i18n,
        hintStyle: AppText.sans(
          16,
          height: 24,
          color: AppPalette.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        counterStyle: AppText.mono(10, height: 14),
        filled: true,
        fillColor: AppPalette.surfaceLow,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.dsp,
          vertical: 14.dsp,
        ),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppPalette.primaryStrong),
        ),
      ),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final TrackOverview overview;
  final bool selected;
  final VoidCallback onTap;

  const _TrackTile({
    required this.overview,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceTile(
      title: overview.track.name.text,
      hint: overview.track.isAvailable ? null : Strings.onboardingSoon.i18n,
      selected: selected,
      onTap: onTap,
      leading: TrackIconBox(trackId: overview.track.id),
    );
  }
}

class _InterviewDateField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime?> onChanged;

  const _InterviewDateField({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(Strings.onboardingInterviewDate.i18n),
        DatePickerField(
          date: date,
          placeholder: Strings.onboardingPickDate.i18n,
          firstDate: today,
          lastDate: today.add(const Duration(days: 365)),
          initialDate: today.add(const Duration(days: 7)),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final radius = BorderRadius.circular(8.dsp);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 16.dsp),
      child: Material(
        color: enabled ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: 52.dsp,
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: 20.dsp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppPalette.onPrimaryStrong,
                      ),
                    )
                  : Text(
                      label,
                      style: AppText.sans(
                        16,
                        height: 24,
                        weight: FontWeight.w600,
                        color: enabled
                            ? AppPalette.onPrimaryStrong
                            : AppPalette.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

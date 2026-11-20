// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/analytics/app_analytics.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';

part 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final GetTracks _getTracks;
  final SaveProfile _saveProfile;
  final AppAnalytics _analytics;

  OnboardingCubit(
    this._getTracks,
    this._saveProfile, {
    AppAnalytics analytics = const NoopAppAnalytics(),
  })  : _analytics = analytics,
        super(const OnboardingState());

  Future<void> load() async {
    final tracks = (await _getTracks()).value ?? const <TrackOverview>[];
    if (!isClosed) emit(state.copyWith(tracks: tracks));
  }

  void setName(String name) => emit(
        state.copyWith(
          name: name.length > LearnerProfile.maxNameLength
              ? name.substring(0, LearnerProfile.maxNameLength)
              : name,
        ),
      );

  void selectRole(TargetRole role) => emit(state.copyWith(role: role));

  void selectExperience(ExperienceLevel experience) =>
      emit(state.copyWith(experience: experience));

  void toggleTrack(String trackId) {
    final stack = [...state.techStack];
    if (!stack.remove(trackId)) stack.add(trackId);
    emit(state.copyWith(techStack: stack));
  }

  void setInterviewDate(DateTime? date) =>
      emit(state.copyWith(interviewDate: () => date));

  void back() {
    if (state.step.index == 0) return;
    emit(state.copyWith(step: OnboardingStep.values[state.step.index - 1]));
  }

  /// Moves to the next step, or saves the profile on the last one.
  Future<void> next() async {
    if (!state.canContinue) return;
    if (!state.isLastStep) {
      emit(state.copyWith(step: OnboardingStep.values[state.step.index + 1]));
      return;
    }
    emit(state.copyWith(saving: true));
    final profile = await _saveProfile(
      ProfileFields(
        displayName: state.name,
        role: state.role!,
        experience: state.experience!,
        techStack: state.techStack,
        interviewDate: state.interviewDate,
      ),
    );
    _analytics
      ..onboardingCompleted(
        role: profile.role.name,
        experience: profile.experience.name,
        stackSize: profile.techStack.length,
        hasInterviewDate: profile.interviewDate != null,
      )
      ..setUserProperty('role', profile.role.name)
      ..setUserProperty('experience', profile.experience.name);
    if (!isClosed) emit(state.copyWith(saving: false, done: true));
  }
}

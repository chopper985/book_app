part of 'onboarding_cubit.dart';

enum OnboardingStep { name, role, experience, stack }

class OnboardingState extends Equatable {
  final OnboardingStep step;
  final String name;
  final TargetRole? role;
  final ExperienceLevel? experience;

  /// Picked track ids, in pick order.
  final List<String> techStack;
  final DateTime? interviewDate;

  /// Every track, available or not, for the tech stack step.
  final List<TrackOverview> tracks;
  final bool saving;
  final bool done;

  const OnboardingState({
    this.step = OnboardingStep.name,
    this.name = '',
    this.role,
    this.experience,
    this.techStack = const [],
    this.interviewDate,
    this.tracks = const [],
    this.saving = false,
    this.done = false,
  });

  int get stepNumber => step.index + 1;

  int get stepCount => OnboardingStep.values.length;

  bool get isLastStep => step == OnboardingStep.values.last;

  bool get canContinue => switch (step) {
        OnboardingStep.name => name.trim().isNotEmpty,
        OnboardingStep.role => role != null,
        OnboardingStep.experience => experience != null,
        OnboardingStep.stack => techStack.isNotEmpty && !saving,
      };

  OnboardingState copyWith({
    OnboardingStep? step,
    String? name,
    TargetRole? role,
    ExperienceLevel? experience,
    List<String>? techStack,
    DateTime? Function()? interviewDate,
    List<TrackOverview>? tracks,
    bool? saving,
    bool? done,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      name: name ?? this.name,
      role: role ?? this.role,
      experience: experience ?? this.experience,
      techStack: techStack ?? this.techStack,
      interviewDate:
          interviewDate == null ? this.interviewDate : interviewDate(),
      tracks: tracks ?? this.tracks,
      saving: saving ?? this.saving,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => [
        step,
        name,
        role,
        experience,
        techStack,
        interviewDate,
        tracks,
        saving,
        done,
      ];
}

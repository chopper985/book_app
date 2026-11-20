// Package imports:
import 'package:equatable/equatable.dart';

/// Position the learner is preparing for.
enum TargetRole { mobile, frontend, backend, fullstack }

/// Experience, used to pick question levels and the header label.
enum ExperienceLevel { student, fresher, junior, middle }

/// Answers of the onboarding, stored on the device. Has [updatedAt] so it can
/// be synced to the cloud later.
class LearnerProfile extends Equatable {
  static const int maxNameLength = 30;

  final String displayName;
  final TargetRole role;
  final ExperienceLevel experience;

  /// Track ids the learner works with, in the order they were picked.
  final List<String> techStack;
  final DateTime? interviewDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearnerProfile({
    required this.displayName,
    required this.role,
    required this.experience,
    required this.techStack,
    required this.createdAt,
    required this.updatedAt,
    this.interviewDate,
  });

  /// Whole days from [now] to the interview; `null` when none is set or it
  /// has passed.
  int? daysToInterview(DateTime now) {
    final date = interviewDate;
    if (date == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final days = (day.difference(today).inHours / 24).round();
    return days < 0 ? null : days;
  }

  @override
  List<Object?> get props => [
        displayName,
        role,
        experience,
        techStack,
        interviewDate,
        createdAt,
        updatedAt,
      ];
}

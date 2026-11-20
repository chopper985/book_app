// Project imports:
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';

abstract class ProfileRepository {
  /// Synchronous so the router can redirect before the first frame.
  LearnerProfile? get profile;

  bool get hasProfile => profile != null;

  /// Creates or replaces the profile, keeping the original `createdAt`.
  Future<LearnerProfile> save({
    required String displayName,
    required TargetRole role,
    required ExperienceLevel experience,
    required List<String> techStack,
    DateTime? interviewDate,
  });

  /// Fires after the profile is saved.
  Stream<void> get changes;
}

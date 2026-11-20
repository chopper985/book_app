// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/repositories/profile_repository.dart';

@injectable
class GetProfile {
  final ProfileRepository _repository;

  GetProfile(this._repository);

  LearnerProfile? call() => _repository.profile;
}

@injectable
class SaveProfile {
  final ProfileRepository _repository;

  SaveProfile(this._repository);

  /// Trims the name; an empty name or stack is rejected by the caller.
  Future<LearnerProfile> call({
    required String displayName,
    required TargetRole role,
    required ExperienceLevel experience,
    required List<String> techStack,
    DateTime? interviewDate,
  }) =>
      _repository.save(
        displayName: displayName.trim(),
        role: role,
        experience: experience,
        techStack: techStack,
        interviewDate: interviewDate,
      );
}

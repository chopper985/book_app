// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/repositories/profile_repository.dart';

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

  Future<LearnerProfile> call(ProfileFields fields) => _repository.save(fields);
}

@injectable
class StoreAvatar {
  final ProfileRepository _repository;

  StoreAvatar(this._repository);

  /// Returns the stored file name.
  Future<String> call(String sourcePath) => _repository.storeAvatar(sourcePath);
}

@injectable
class GetAvatarPath {
  final ProfileRepository _repository;

  GetAvatarPath(this._repository);

  Future<String?> call(String? fileName) async =>
      fileName == null ? null : _repository.avatarPath(fileName);
}

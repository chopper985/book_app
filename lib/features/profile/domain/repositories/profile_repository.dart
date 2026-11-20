// Project imports:
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';

abstract class ProfileRepository {
  /// Synchronous so the router can redirect before the first frame.
  LearnerProfile? get profile;

  bool get hasProfile => profile != null;

  /// Creates or replaces the profile, keeping the original `createdAt`.
  /// [fields] are normalized (trimmed, blank optional text removed).
  Future<LearnerProfile> save(ProfileFields fields);

  /// Copies the picked image into app storage and returns its file name.
  Future<String> storeAvatar(String sourcePath);

  /// Absolute path of a stored avatar, `null` when the file is missing.
  Future<String?> avatarPath(String fileName);

  /// Fires after the profile is saved.
  Stream<void> get changes;
}

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/features/profile/data/datasources/avatar_local_datasource.dart';
import 'package:interview_practice/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileLocalDataSource _local;
  final AvatarLocalDataSource _avatars;
  final AppClock _clock;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  ProfileRepositoryImpl(this._local, this._avatars, this._clock);

  @override
  LearnerProfile? get profile => _local.read();

  @override
  bool get onboardingCompleted => _local.readOnboarded() || profile != null;

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<LearnerProfile> save(ProfileFields fields) async {
    final now = _clock.now();
    final previous = _local.read();
    final profile = LearnerProfile(
      fields: fields.normalized(),
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );
    await _local.write(profile);
    await _local.writeOnboarded();
    // Replaced or removed avatars are deleted only once the profile no
    // longer points to them.
    if (previous?.avatarFileName != profile.avatarFileName) {
      await _avatars.prune(keep: profile.avatarFileName);
    }
    _changes.add(null);
    return profile;
  }

  @override
  Future<void> restore(LearnerProfile? profile) async {
    if (profile == null) {
      // Profiles saved before the onboarding flag existed: keep onboarding
      // completed when the profile is cleared (sign-out).
      if (_local.read() != null) await _local.writeOnboarded();
      await _local.clear();
    } else {
      await _local.write(profile);
      await _local.writeOnboarded();
    }
    _changes.add(null);
  }

  @override
  Future<String> storeAvatar(String sourcePath) => _avatars.store(sourcePath);

  @override
  Future<String?> avatarPath(String fileName) => _avatars.pathOf(fileName);
}

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileLocalDataSource _local;
  final AppClock _clock;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  ProfileRepositoryImpl(this._local, this._clock);

  @override
  LearnerProfile? get profile => _local.read();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<LearnerProfile> save({
    required String displayName,
    required TargetRole role,
    required ExperienceLevel experience,
    required List<String> techStack,
    DateTime? interviewDate,
  }) async {
    final now = _clock.now();
    final profile = LearnerProfile(
      displayName: displayName,
      role: role,
      experience: experience,
      techStack: List.unmodifiable(techStack),
      interviewDate: interviewDate,
      createdAt: _local.read()?.createdAt ?? now,
      updatedAt: now,
    );
    await _local.write(profile);
    _changes.add(null);
    return profile;
  }
}

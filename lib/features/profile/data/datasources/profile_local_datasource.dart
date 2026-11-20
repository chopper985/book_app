// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/constants/storage_key.dart';
import 'package:interview_practice/features/profile/data/models/profile_json.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';

abstract class ProfileLocalDataSource {
  LearnerProfile? read();

  Future<void> write(LearnerProfile profile);
}

@LazySingleton(as: ProfileLocalDataSource)
class HiveProfileLocalDataSource implements ProfileLocalDataSource {
  static const String _key = 'current';

  Box<String> get _box => Hive.box<String>(StorageKeys.profileBox);

  /// An unreadable profile counts as none, so onboarding runs again.
  @override
  LearnerProfile? read() {
    final raw = _box.get(_key);
    if (raw == null) return null;
    try {
      return ProfileJson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Unreadable profile: $error');
      return null;
    }
  }

  @override
  Future<void> write(LearnerProfile profile) =>
      _box.put(_key, jsonEncode(ProfileJson.toJson(profile)));
}

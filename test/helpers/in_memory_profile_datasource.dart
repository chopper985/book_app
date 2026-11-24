// Project imports:
import 'package:interview_practice/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:interview_practice/features/profile/data/models/profile_json.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';

/// Keeps the profile as a JSON map, so tests also exercise the mapping.
class InMemoryProfileLocalDataSource implements ProfileLocalDataSource {
  Map<String, dynamic>? json;
  bool onboarded = false;

  @override
  LearnerProfile? read() => json == null ? null : ProfileJson.fromJson(json!);

  @override
  Future<void> clear() async => json = null;

  @override
  bool readOnboarded() => onboarded;

  @override
  Future<void> writeOnboarded() async => onboarded = true;

  @override
  Future<void> write(LearnerProfile profile) async =>
      json = ProfileJson.toJson(profile);
}

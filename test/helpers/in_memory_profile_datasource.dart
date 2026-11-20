// Project imports:
import 'package:AppName/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:AppName/features/profile/data/models/profile_json.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';

/// Keeps the profile as a JSON map, so tests also exercise the mapping.
class InMemoryProfileLocalDataSource implements ProfileLocalDataSource {
  Map<String, dynamic>? json;

  @override
  LearnerProfile? read() => json == null ? null : ProfileJson.fromJson(json!);

  @override
  Future<void> write(LearnerProfile profile) async =>
      json = ProfileJson.toJson(profile);
}

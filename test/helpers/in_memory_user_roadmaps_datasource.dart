// Project imports:
import 'package:AppName/features/catalog/data/datasources/user_roadmaps_local_datasource.dart';

/// Keeps the JSON document, so tests also exercise the mapping.
class InMemoryUserRoadmapsLocalDataSource
    implements UserRoadmapsLocalDataSource {
  Map<String, dynamic>? json;

  @override
  UserRoadmapsData read() => json == null
      ? (roadmaps: const [], activeId: null)
      : UserRoadmapsJson.fromJson(json!);

  @override
  Future<void> write(UserRoadmapsData data) async =>
      json = UserRoadmapsJson.toJson(data);
}

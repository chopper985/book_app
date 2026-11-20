// Project imports:
import 'package:AppName/features/catalog/domain/entities/user_roadmap.dart';
import 'package:AppName/features/content/domain/entities/question.dart';

abstract class UserRoadmapsRepository {
  /// Most recently added first.
  List<UserRoadmap> get roadmaps;

  /// The roadmap shown in the Roadmaps tab; `null` when none was added.
  UserRoadmap? get active;

  /// Adds the roadmap (or reuses the same track + level) and makes it active.
  Future<UserRoadmap> add(String trackId, QuestionLevel level);

  Future<void> select(String roadmapId);

  /// Removes it; the newest remaining one becomes active.
  Future<void> remove(String roadmapId);

  Stream<void> get changes;
}

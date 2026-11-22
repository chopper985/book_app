// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

abstract class UserRoadmapsRepository {
  /// Most recently selected (or added) first.
  List<UserRoadmap> get roadmaps;

  /// The roadmap shown in the Roadmaps tab; `null` when none was added.
  UserRoadmap? get active;

  /// Adds the roadmap (or reuses the same track + level) and makes it active.
  Future<UserRoadmap> add(String trackId, QuestionLevel level);

  /// Same for a position option; [mainTrackId] is shown as its icon.
  Future<UserRoadmap> addPosition({
    required String positionId,
    required String optionId,
    required String mainTrackId,
    required QuestionLevel level,
  });

  /// Makes it active and moves it to the top of [roadmaps].
  Future<void> select(String roadmapId);

  /// Removes it; the most recently selected remaining one becomes active.
  Future<void> remove(String roadmapId);

  /// Replaces every roadmap and the active one (cloud sync, sign-out).
  Future<void> replaceAll(List<UserRoadmap> roadmaps, String? activeId);

  Stream<void> get changes;
}

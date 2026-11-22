// Project imports:
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';
import 'package:interview_practice/features/sync/domain/repositories/cloud_sync_repository.dart';

/// Cloud copy per uid, with a log of uploaded result ids.
class InMemoryCloudSyncRepository implements CloudSyncRepository {
  final Map<String, LearnerSnapshot> stored = {};
  final List<String> uploadedResultIds = [];
  int pushes = 0;

  @override
  Future<LearnerSnapshot?> fetch(String uid) async => stored[uid];

  @override
  Future<void> push(
    String uid,
    LearnerSnapshot snapshot, {
    Set<String> knownResultIds = const {},
  }) async {
    pushes++;
    uploadedResultIds.addAll([
      for (final result in snapshot.results)
        if (!knownResultIds.contains(result.sessionId)) result.sessionId,
    ]);
    final previous = stored[uid]?.results ?? const [];
    final ids = {for (final r in snapshot.results) r.sessionId};
    stored[uid] = LearnerSnapshot(
      profile: snapshot.profile,
      results: [
        ...snapshot.results,
        for (final r in previous)
          if (!ids.contains(r.sessionId)) r,
      ],
      roadmaps: snapshot.roadmaps,
      activeRoadmapId: snapshot.activeRoadmapId,
      savedTrackIds: snapshot.savedTrackIds,
      extraSessionsUsed: snapshot.extraSessionsUsed,
    );
  }

  @override
  Future<void> deleteResults(String uid) async {
    final current = stored[uid];
    if (current == null) return;
    stored[uid] = LearnerSnapshot(
      profile: current.profile,
      roadmaps: current.roadmaps,
      activeRoadmapId: current.activeRoadmapId,
      savedTrackIds: current.savedTrackIds,
    );
  }

  @override
  Future<void> deleteAll(String uid) async => stored.remove(uid);
}

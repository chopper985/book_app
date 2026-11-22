// Project imports:
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';

/// Combines the device data with the cloud copy without losing either:
/// - results: union by session id (a result never changes once graded);
/// - profile: the most recently updated one wins, the avatar file name of
///   the device is kept because images are not synced;
/// - roadmaps and saved tracks: device order first, then the cloud extras;
///   the device's active roadmap wins when it exists.
class MergeSnapshots {
  const MergeSnapshots();

  LearnerSnapshot call(LearnerSnapshot local, LearnerSnapshot? remote) {
    if (remote == null) return local;

    final resultIds = local.resultIds;
    final results = [
      ...local.results,
      for (final result in remote.results)
        if (!resultIds.contains(result.sessionId)) result,
    ]..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));

    final roadmapIds = {for (final r in local.roadmaps) r.id};
    final roadmaps = [
      ...local.roadmaps,
      for (final roadmap in remote.roadmaps)
        if (!roadmapIds.contains(roadmap.id)) roadmap,
    ];
    final activeId = local.activeRoadmapId != null &&
            roadmapIds.contains(local.activeRoadmapId)
        ? local.activeRoadmapId
        : remote.activeRoadmapId;

    return LearnerSnapshot(
      profile: _profile(local.profile, remote.profile),
      results: results,
      roadmaps: roadmaps,
      activeRoadmapId: activeId,
      savedTrackIds: {...local.savedTrackIds, ...remote.savedTrackIds}.toList(),
    );
  }

  LearnerProfile? _profile(LearnerProfile? local, LearnerProfile? remote) {
    if (local == null) return remote;
    if (remote == null || !remote.updatedAt.isAfter(local.updatedAt)) {
      return local;
    }
    return LearnerProfile(
      fields: remote.fields.copyWith(avatarFileName: () => local.avatarFileName),
      createdAt: local.createdAt.isBefore(remote.createdAt)
          ? local.createdAt
          : remote.createdAt,
      updatedAt: remote.updatedAt,
    );
  }
}

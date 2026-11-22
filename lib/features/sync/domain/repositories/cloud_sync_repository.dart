// Project imports:
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';

/// The learner's copy in the cloud, keyed by Firebase uid.
abstract class CloudSyncRepository {
  /// `null` when nothing was stored yet.
  Future<LearnerSnapshot?> fetch(String uid);

  /// Writes the profile, roadmaps and saved tracks, and uploads the results
  /// whose ids are not in [knownResultIds].
  Future<void> push(
    String uid,
    LearnerSnapshot snapshot, {
    Set<String> knownResultIds = const {},
  });

  Future<void> deleteResults(String uid);

  /// Removes everything stored for [uid] (account deletion).
  Future<void> deleteAll(String uid);
}

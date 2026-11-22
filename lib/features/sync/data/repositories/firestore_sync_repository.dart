// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_firebase.dart';
import 'package:interview_practice/features/catalog/data/datasources/user_roadmaps_local_datasource.dart';
import 'package:interview_practice/features/practice/data/models/practice_json.dart';
import 'package:interview_practice/features/profile/data/models/profile_json.dart';
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';
import 'package:interview_practice/features/sync/domain/repositories/cloud_sync_repository.dart';

/// Layout: `users/{uid}` holds profile, roadmaps and saved tracks;
/// `users/{uid}/results/{sessionId}` holds one graded session each.
/// Rules in `firestore.rules` restrict both to the owner.
@LazySingleton(as: CloudSyncRepository)
class FirestoreSyncRepository implements CloudSyncRepository {
  /// Firestore batches accept at most 500 writes.
  static const int _batchLimit = 400;

  FirebaseFirestore? get _db =>
      AppFirebase.isReady ? FirebaseFirestore.instance : null;

  DocumentReference<Map<String, dynamic>> _user(
    FirebaseFirestore db,
    String uid,
  ) =>
      db.collection('users').doc(uid);

  @override
  Future<LearnerSnapshot?> fetch(String uid) async {
    final db = _db;
    if (db == null) return null;
    final doc = await _user(db, uid).get();
    final results = await _user(db, uid).collection('results').get();
    if (!doc.exists && results.docs.isEmpty) return null;

    final data = doc.data() ?? const <String, dynamic>{};
    final profile = data['profile'];
    final roadmaps = data['roadmaps'];
    final roadmapData = roadmaps is Map<String, dynamic>
        ? UserRoadmapsJson.fromJson(roadmaps)
        : null;
    return LearnerSnapshot(
      profile: profile is Map<String, dynamic>
          ? ProfileJson.fromJson(profile)
          : null,
      results: [
        for (final result in results.docs)
          PracticeJson.resultFrom(result.data()),
      ],
      roadmaps: roadmapData?.roadmaps ?? const [],
      activeRoadmapId: roadmapData?.activeId,
      savedTrackIds: List<String>.from(
        data['savedTrackIds'] as List? ?? const [],
      ),
      extraSessionsUsed: (data['extraSessionsUsed'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<void> push(
    String uid,
    LearnerSnapshot snapshot, {
    Set<String> knownResultIds = const {},
  }) async {
    final db = _db;
    if (db == null) return;
    final user = _user(db, uid);
    final profile = snapshot.profile;
    await user.set({
      // The avatar is an image file on the device; it is not uploaded.
      'profile': profile == null
          ? null
          : (ProfileJson.toJson(profile)..remove('avatar')),
      'roadmaps': UserRoadmapsJson.toJson(
        (roadmaps: snapshot.roadmaps, activeId: snapshot.activeRoadmapId),
      ),
      'savedTrackIds': snapshot.savedTrackIds,
      'extraSessionsUsed': snapshot.extraSessionsUsed,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final pending = [
      for (final result in snapshot.results)
        if (!knownResultIds.contains(result.sessionId)) result,
    ];
    for (var i = 0; i < pending.length; i += _batchLimit) {
      final batch = db.batch();
      for (final result in pending.skip(i).take(_batchLimit)) {
        batch.set(
          user.collection('results').doc(result.sessionId),
          PracticeJson.result(result),
        );
      }
      await batch.commit();
    }
  }

  @override
  Future<void> deleteResults(String uid) async {
    final db = _db;
    if (db == null) return;
    await _deleteCollection(db, _user(db, uid).collection('results'));
  }

  @override
  Future<void> deleteAll(String uid) async {
    final db = _db;
    if (db == null) return;
    await deleteResults(uid);
    await _user(db, uid).delete();
  }

  Future<void> _deleteCollection(
    FirebaseFirestore db,
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final page = await collection.limit(_batchLimit).get();
      if (page.docs.isEmpty) return;
      final batch = db.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}

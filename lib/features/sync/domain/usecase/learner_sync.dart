// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/domain/repositories/auth_repository.dart';
import 'package:interview_practice/features/catalog/domain/repositories/saved_tracks_repository.dart';
import 'package:interview_practice/features/catalog/domain/repositories/user_roadmaps_repository.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_repository.dart';
import 'package:interview_practice/features/premium/domain/repositories/usage_repository.dart';
import 'package:interview_practice/features/profile/domain/repositories/profile_repository.dart';
import 'package:interview_practice/features/sync/domain/entities/guest_data_prompt.dart';
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';
import 'package:interview_practice/features/sync/domain/repositories/cloud_sync_repository.dart';
import 'package:interview_practice/features/sync/domain/usecase/merge_snapshots.dart';

/// Keeps the device and the cloud copy of a linked account in step: merges
/// both when the account is linked or signed in, then pushes local changes
/// (debounced). Anonymous accounts are not synced.
///
/// Signing in to an existing account from guest mode adopts the account:
/// its profile wins, and when the device holds guest results the learner is
/// asked (see [guestDataPrompt]) whether to merge them or drop them.
@lazySingleton
class LearnerSync {
  static const Duration debounce = Duration(seconds: 2);

  final AuthRepository _auth;
  final CloudSyncRepository _cloud;
  final PracticeRepository _practice;
  final ProfileRepository _profile;
  final SavedTracksRepository _saved;
  final UserRoadmapsRepository _roadmaps;
  final UsageRepository _usage;
  final MergeSnapshots _merge = const MergeSnapshots();

  StreamSubscription<AuthUser?>? _authSubscription;
  AuthUser? _lastUser;

  /// Per signed-in uid: the guest-data question, or `null` when none.
  final Map<String, Completer<GuestDataPrompt?>> _prompts = {};
  final List<StreamSubscription<void>> _localSubscriptions = [];
  Timer? _pushTimer;
  String? _uid;

  /// Result ids already in the cloud, so pushes only upload new ones.
  Set<String> _cloudResultIds = {};
  bool _applying = false;

  LearnerSync(
    this._auth,
    this._cloud,
    this._practice,
    this._profile,
    this._saved,
    this._roadmaps,
    this._usage,
  );

  /// The uid being synced, `null` while anonymous or signed out.
  String? get syncingUid => _uid;

  void start() {
    _authSubscription ??= _auth.userChanges.listen(_onUser);
  }

  /// Completes once the sign-in to [uid] has been inspected: with a prompt
  /// the UI must answer, or `null` when the data was handled without asking.
  Future<GuestDataPrompt?> guestDataPrompt(String uid) =>
      _prompts.putIfAbsent(uid, Completer<GuestDataPrompt?>.new).future;

  void _settlePrompt(String uid, GuestDataPrompt? prompt) {
    final completer =
        _prompts.putIfAbsent(uid, Completer<GuestDataPrompt?>.new);
    if (!completer.isCompleted) completer.complete(prompt);
  }

  Future<void> _onUser(AuthUser? user) async {
    final previous = _lastUser;
    _lastUser = user;
    final uid = user != null && user.isLinked ? user.uid : null;
    if (uid == _uid) return;
    detach();
    if (uid == null) return;
    _uid = uid;
    final fromGuest =
        previous != null && previous.isAnonymous && previous.uid != uid;
    if (fromGuest) {
      await _adoptAccount(uid);
    } else {
      _settlePrompt(uid, null);
      await syncNow();
    }
    if (_uid != uid) return;
    _localSubscriptions.addAll([
      for (final stream in [
        _practice.changes,
        _profile.changes,
        _saved.changes,
        _roadmaps.changes,
        _usage.changes,
      ])
        stream.listen((_) => _schedulePush()),
    ]);
  }

  /// Merges the cloud copy into the device and uploads the result.
  Future<void> syncNow() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final remote = await _cloud.fetch(uid);
      final local = await _localSnapshot();
      final merged = _merge(local, remote);
      await _applyLocally(local, merged);
      await _cloud.push(
        uid,
        merged,
        knownResultIds: remote?.resultIds ?? const {},
      );
      _cloudResultIds = merged.resultIds;
    } catch (error) {
      // Offline or rules not deployed: local data stays the source of truth.
      debugPrint('Sync failed: $error');
    }
  }

  /// Guest → existing account: the account's profile wins; guest results
  /// join the account only if the learner agrees.
  Future<void> _adoptAccount(String uid) async {
    try {
      final remote = await _cloud.fetch(uid);
      final local = await _localSnapshot();
      final prompt = remote != null && local.results.isNotEmpty
          ? GuestDataPrompt(local.results.length)
          : null;
      _settlePrompt(uid, prompt);
      final keep = prompt == null || await prompt.keepGuestProgress;
      if (_uid != uid) return;
      final merged =
          _merge.adoptAccount(local, remote, keepGuestProgress: keep);
      await _applyLocally(local, merged, replaceResults: !keep);
      await _cloud.push(
        uid,
        merged,
        knownResultIds: remote?.resultIds ?? const {},
      );
      _cloudResultIds = merged.resultIds;
    } catch (error) {
      _settlePrompt(uid, null);
      debugPrint('Adopting the account failed: $error');
    }
  }

  /// Pushes pending local changes now (before signing out).
  Future<void> flush() async {
    if (_pushTimer?.isActive ?? false) {
      _pushTimer!.cancel();
      await _push();
    }
  }

  /// Stops syncing the current account (sign-out, account switch).
  void detach() {
    _pushTimer?.cancel();
    for (final subscription in _localSubscriptions) {
      subscription.cancel();
    }
    _localSubscriptions.clear();
    _uid = null;
    _cloudResultIds = {};
  }

  /// Stops listening to the account (tests, app teardown).
  Future<void> dispose() async {
    detach();
    await _authSubscription?.cancel();
    _authSubscription = null;
  }

  /// Deletes the cloud results too, so a progress reset is not undone by the
  /// next merge.
  Future<void> clearCloudHistory() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _cloud.deleteResults(uid);
      _cloudResultIds = {};
    } catch (error) {
      debugPrint('Clearing cloud history failed: $error');
    }
  }

  /// Deletes every cloud copy of the current account.
  Future<void> deleteCloudData() async {
    final uid = _uid;
    if (uid == null) return;
    await _cloud.deleteAll(uid);
    _cloudResultIds = {};
  }

  void _schedulePush() {
    if (_applying || _uid == null) return;
    _pushTimer?.cancel();
    _pushTimer = Timer(debounce, _push);
  }

  Future<void> _push() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final snapshot = await _localSnapshot();
      await _cloud.push(uid, snapshot, knownResultIds: _cloudResultIds);
      _cloudResultIds = snapshot.resultIds;
    } catch (error) {
      debugPrint('Sync push failed: $error');
    }
  }

  Future<LearnerSnapshot> _localSnapshot() async => LearnerSnapshot(
        profile: _profile.profile,
        results: await _practice.getResults(),
        roadmaps: _roadmaps.roadmaps,
        activeRoadmapId: _roadmaps.active?.id,
        savedTrackIds: _saved.savedTrackIds,
        extraSessionsUsed: _usage.extraSessionsUsed,
      );

  /// Writes only what changed, without triggering pushes of its own.
  Future<void> _applyLocally(
    LearnerSnapshot local,
    LearnerSnapshot merged, {
    bool replaceResults = false,
  }) async {
    _applying = true;
    try {
      if (merged.profile != local.profile) {
        await _profile.restore(merged.profile);
      }
      if (replaceResults) {
        // Guest progress dropped: the device keeps only the account's.
        await _practice.clearHistory();
        if (merged.results.isNotEmpty) {
          await _practice.importResults(merged.results);
        }
      } else {
        final localIds = local.resultIds;
        final incoming = [
          for (final result in merged.results)
            if (!localIds.contains(result.sessionId)) result,
        ];
        if (incoming.isNotEmpty) await _practice.importResults(incoming);
      }
      if (!listEquals(merged.savedTrackIds, local.savedTrackIds)) {
        await _saved.replaceAll(merged.savedTrackIds);
      }
      if (!listEquals(merged.roadmaps, local.roadmaps) ||
          merged.activeRoadmapId != local.activeRoadmapId) {
        await _roadmaps.replaceAll(merged.roadmaps, merged.activeRoadmapId);
      }
      if (merged.extraSessionsUsed != local.extraSessionsUsed) {
        await _usage.restoreExtraSessionsUsed(merged.extraSessionsUsed);
      }
    } finally {
      // Change events of the writes above are delivered asynchronously.
      await Future<void>.delayed(Duration.zero);
      _applying = false;
    }
  }
}

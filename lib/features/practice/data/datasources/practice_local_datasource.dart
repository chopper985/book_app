// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/constants/storage_key.dart';
import 'package:interview_practice/features/practice/data/models/practice_json.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_session.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';

/// Stores unfinished sessions and graded results on the device.
abstract class PracticeLocalDataSource {
  PracticeSession? session(String id);

  List<PracticeSession> sessions();

  Future<void> putSession(PracticeSession session);

  Future<void> deleteSession(String id);

  SessionResult? result(String sessionId);

  List<SessionResult> results();

  Future<void> putResult(SessionResult result);

  Future<void> clear();
}

/// Each entry is a JSON string keyed by session id. Entries that fail to
/// decode (older or corrupted data) are skipped instead of crashing the app.
@LazySingleton(as: PracticeLocalDataSource)
class HivePracticeLocalDataSource implements PracticeLocalDataSource {
  Box<String> get _sessions =>
      Hive.box<String>(StorageKeys.practiceSessionsBox);

  Box<String> get _results => Hive.box<String>(StorageKeys.practiceResultsBox);

  @override
  PracticeSession? session(String id) =>
      _decode(_sessions.get(id), PracticeJson.sessionFrom);

  @override
  List<PracticeSession> sessions() => _sessions.values
      .map((raw) => _decode(raw, PracticeJson.sessionFrom))
      .nonNulls
      .toList();

  @override
  Future<void> putSession(PracticeSession session) =>
      _sessions.put(session.id, jsonEncode(PracticeJson.session(session)));

  @override
  Future<void> deleteSession(String id) => _sessions.delete(id);

  @override
  SessionResult? result(String sessionId) =>
      _decode(_results.get(sessionId), PracticeJson.resultFrom);

  @override
  List<SessionResult> results() => _results.values
      .map((raw) => _decode(raw, PracticeJson.resultFrom))
      .nonNulls
      .toList();

  @override
  Future<void> putResult(SessionResult result) => _results.put(
        result.sessionId,
        jsonEncode(PracticeJson.result(result)),
      );

  @override
  Future<void> clear() async {
    await _sessions.clear();
    await _results.clear();
  }

  T? _decode<T>(String? raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw == null) return null;
    try {
      return fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (error) {
      debugPrint('Skipping unreadable practice entry: $error');
      return null;
    }
  }
}

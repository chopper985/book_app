// Project imports:
import 'package:interview_practice/features/practice/data/datasources/practice_local_datasource.dart';
import 'package:interview_practice/features/practice/data/models/practice_json.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_session.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';

/// Keeps entries as JSON maps, so tests also exercise the storage mapping.
class InMemoryPracticeLocalDataSource implements PracticeLocalDataSource {
  final Map<String, Map<String, dynamic>> sessionJson = {};
  final Map<String, Map<String, dynamic>> resultJson = {};

  @override
  PracticeSession? session(String id) {
    final json = sessionJson[id];
    return json == null ? null : PracticeJson.sessionFrom(json);
  }

  @override
  List<PracticeSession> sessions() =>
      sessionJson.values.map(PracticeJson.sessionFrom).toList();

  @override
  Future<void> putSession(PracticeSession session) async =>
      sessionJson[session.id] = PracticeJson.session(session);

  @override
  Future<void> deleteSession(String id) async => sessionJson.remove(id);

  @override
  SessionResult? result(String sessionId) {
    final json = resultJson[sessionId];
    return json == null ? null : PracticeJson.resultFrom(json);
  }

  @override
  List<SessionResult> results() =>
      resultJson.values.map(PracticeJson.resultFrom).toList();

  @override
  Future<void> putResult(SessionResult result) async =>
      resultJson[result.sessionId] = PracticeJson.result(result);

  @override
  Future<void> clear() async {
    sessionJson.clear();
    resultJson.clear();
  }
}

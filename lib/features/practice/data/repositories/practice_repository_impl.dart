// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/entities/quiz_set.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import 'package:AppName/features/practice/data/datasources/practice_local_datasource.dart';
import 'package:AppName/features/practice/domain/entities/practice_bundle.dart';
import 'package:AppName/features/practice/domain/entities/practice_failures.dart';
import 'package:AppName/features/practice/domain/entities/practice_session.dart';
import 'package:AppName/features/practice/domain/entities/session_result.dart';
import 'package:AppName/features/practice/domain/repositories/practice_repository.dart';
import 'package:AppName/features/practice/domain/usecase/score_session.dart';

/// Sessions and results persisted through [PracticeLocalDataSource]. A
/// session is removed once graded: its result keeps everything needed.
@LazySingleton(as: PracticeRepository)
class PracticeRepositoryImpl implements PracticeRepository {
  final ContentRepository _contentRepository;
  final PracticeLocalDataSource _local;
  final AppClock _clock;
  final ScoreSession _scoreSession = const ScoreSession();
  final StreamController<void> _changes = StreamController<void>.broadcast();

  int _sequence = 0;

  PracticeRepositoryImpl(this._contentRepository, this._local, this._clock);

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<Result<PracticeBundle>> startSession(
    String setId, {
    List<String>? onlyQuestionIds,
  }) async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final set = _setById(catalog, setId);
    if (set == null || catalog.trackById(set.trackId) == null) {
      return Result.failure(QuizSetNotFoundFailure(setId));
    }

    final questionIds = onlyQuestionIds == null
        ? set.questionIds
        : set.questionIds.where(onlyQuestionIds.contains).toList();
    if (questionIds.isEmpty) {
      return Result.failure(QuizSetNotFoundFailure(setId));
    }

    final now = _clock.now();
    final session = PracticeSession(
      id: '$setId-${now.microsecondsSinceEpoch}-${_sequence++}',
      setId: setId,
      trackId: set.trackId,
      questionIds: List.unmodifiable(questionIds),
      startedAt: now,
      endsAt: set.durationMinutes == null
          ? null
          : now.add(Duration(minutes: set.durationMinutes!)),
    );
    await _local.putSession(session);
    _changes.add(null);

    return _practiceBundle(session, catalog);
  }

  @override
  Future<Result<PracticeBundle>> resumeSession(String sessionId) async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final session = _local.session(sessionId);
    if (session == null ||
        _local.result(sessionId) != null ||
        session.isExpiredAt(_clock.now())) {
      return Result.failure(SessionNotFoundFailure(sessionId));
    }
    return _practiceBundle(session, catalog);
  }

  @override
  Future<void> saveSession(PracticeSession session) async {
    if (_local.result(session.id) != null) return;
    await _local.putSession(session.copyWith(updatedAt: _clock.now()));
    _changes.add(null);
  }

  @override
  Future<Result<ResultBundle>> submit(
    String sessionId, {
    bool timedOut = false,
  }) async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final existing = _local.result(sessionId);
    if (existing != null) return _resultBundle(existing, catalog);

    final session = _local.session(sessionId);
    if (session == null) {
      return Result.failure(SessionNotFoundFailure(sessionId));
    }

    final questions = {
      for (final id in session.questionIds) id: catalog.questionById(id),
    };
    if (questions.values.contains(null)) {
      return Result.failure(QuizSetNotFoundFailure(session.setId));
    }

    final result = _scoreSession(
      session,
      questions.cast(),
      submittedAt: _clock.now(),
      timedOut: timedOut,
    );
    await _local.putResult(result);
    await _local.deleteSession(sessionId);
    _changes.add(null);
    return _resultBundle(result, catalog);
  }

  @override
  Future<Result<ResultBundle>> getResult(String sessionId) async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final result = _local.result(sessionId);
    if (result == null) {
      return Result.failure(SessionNotFoundFailure(sessionId));
    }
    return _resultBundle(result, catalog);
  }

  @override
  Future<List<SessionResult>> getResults() async =>
      _local.results()..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));

  @override
  Future<PracticeSession?> getLatestUnfinished() async {
    final now = _clock.now();
    PracticeSession? latest;
    for (final session in _local.sessions()) {
      if (session.isExpiredAt(now)) continue;
      if (latest == null || session.updatedAt.isAfter(latest.updatedAt)) {
        latest = session;
      }
    }
    return latest;
  }

  @override
  Future<void> clearHistory() async {
    await _local.clear();
    _changes.add(null);
  }

  /// Fails when content changed and a question of the session is gone.
  Result<PracticeBundle> _practiceBundle(
    PracticeSession session,
    ContentCatalog catalog,
  ) {
    final set = _setById(catalog, session.setId);
    final track = catalog.trackById(session.trackId);
    final questions = session.questionIds.map(catalog.questionById).toList();
    if (set == null || track == null || questions.contains(null)) {
      return Result.failure(QuizSetNotFoundFailure(session.setId));
    }
    return Result.success(
      PracticeBundle(
        session: session,
        set: set,
        track: track,
        questions: questions.nonNulls.toList(),
      ),
    );
  }

  Result<ResultBundle> _resultBundle(
    SessionResult result,
    ContentCatalog catalog,
  ) {
    final set = _setById(catalog, result.setId);
    final track = catalog.trackById(result.trackId);
    if (set == null || track == null) {
      return Result.failure(QuizSetNotFoundFailure(result.setId));
    }
    return Result.success(
      ResultBundle(
        result: result,
        set: set,
        track: track,
        questions: {
          for (final item in result.items)
            if (catalog.questionById(item.questionId) case final question?)
              item.questionId: question,
        },
      ),
    );
  }

  QuizSet? _setById(ContentCatalog catalog, String setId) {
    for (final set in catalog.sets) {
      if (set.id == setId) return set;
    }
    return null;
  }
}

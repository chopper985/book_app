// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/entities/quiz_set.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import 'package:AppName/features/practice/domain/entities/practice_bundle.dart';
import 'package:AppName/features/practice/domain/entities/practice_failures.dart';
import 'package:AppName/features/practice/domain/entities/practice_session.dart';
import 'package:AppName/features/practice/domain/entities/session_result.dart';
import 'package:AppName/features/practice/domain/repositories/practice_repository.dart';
import 'package:AppName/features/practice/domain/usecase/score_session.dart';

/// In-memory sessions and results. PR 3 moves them to Hive.
@LazySingleton(as: PracticeRepository)
class PracticeRepositoryImpl implements PracticeRepository {
  final ContentRepository _contentRepository;
  final AppClock _clock;
  final ScoreSession _scoreSession = const ScoreSession();

  final Map<String, PracticeSession> _sessions = {};
  final Map<String, SessionResult> _results = {};
  int _sequence = 0;

  PracticeRepositoryImpl(this._contentRepository, this._clock);

  @override
  Future<Result<PracticeBundle>> startSession(
    String setId, {
    List<String>? onlyQuestionIds,
  }) async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final set = _setById(catalog, setId);
    final track = set == null ? null : catalog.trackById(set.trackId);
    if (set == null || track == null) {
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
    _sessions[session.id] = session;

    return Result.success(
      PracticeBundle(
        session: session,
        set: set,
        track: track,
        questions: [for (final id in questionIds) catalog.questionById(id)!],
      ),
    );
  }

  @override
  Future<void> saveSession(PracticeSession session) async {
    if (_results.containsKey(session.id)) return;
    _sessions[session.id] = session;
  }

  @override
  Future<Result<ResultBundle>> submit(
    String sessionId, {
    bool timedOut = false,
  }) async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final existing = _results[sessionId];
    if (existing != null) return _bundle(existing, catalog);

    final session = _sessions[sessionId];
    if (session == null) {
      return Result.failure(SessionNotFoundFailure(sessionId));
    }

    final result = _scoreSession(
      session,
      {
        for (final id in session.questionIds) id: catalog.questionById(id)!,
      },
      submittedAt: _clock.now(),
      timedOut: timedOut,
    );
    _results[sessionId] = result;
    return _bundle(result, catalog);
  }

  @override
  Future<Result<ResultBundle>> getResult(String sessionId) async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final result = _results[sessionId];
    if (result == null) {
      return Result.failure(SessionNotFoundFailure(sessionId));
    }
    return _bundle(result, catalog);
  }

  Result<ResultBundle> _bundle(SessionResult result, ContentCatalog catalog) {
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
            item.questionId: catalog.questionById(item.questionId)!,
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

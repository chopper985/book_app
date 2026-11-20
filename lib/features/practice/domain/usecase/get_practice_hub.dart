// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/entities/quiz_set.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import 'package:AppName/features/practice/domain/entities/practice_hub.dart';
import 'package:AppName/features/practice/domain/entities/session_result.dart';
import 'package:AppName/features/practice/domain/repositories/practice_repository.dart';
import 'package:AppName/features/profile/domain/repositories/profile_repository.dart';

/// Builds the Practice tab from history and content.
@injectable
class GetPracticeHub {
  final ContentRepository _contentRepository;
  final PracticeRepository _practiceRepository;
  final ProfileRepository _profileRepository;

  GetPracticeHub(
    this._contentRepository,
    this._practiceRepository,
    this._profileRepository,
  );

  Future<Result<PracticeHub>> call() async {
    final catalogResult = await _contentRepository.loadCatalog();
    final catalog = catalogResult.value;
    if (catalog == null) return Result.failure(catalogResult.error!);

    final results = await _practiceRepository.getResults();
    final sets = {for (final set in catalog.sets) set.id: set};
    final scored = results.where((result) => result.gradedCount > 0).toList();

    return Result.success(
      PracticeHub(
        mistakes: _mistakes(results, sets, catalog),
        quickPractices: _quickPractices(catalog),
        history: [
          for (final result in results.reversed)
            if ((sets[result.setId], catalog.trackById(result.trackId))
                case (final set?, final track?))
              HistoryEntry(result: result, set: set, track: track),
        ].take(PracticeHub.historyLimit).toList(),
        sessionCount: results.length,
        averageScorePercent: scored.isEmpty
            ? 0
            : (scored.fold(0, (sum, r) => sum + r.scorePercent) /
                    scored.length)
                .round(),
      ),
    );
  }

  /// Latest attempt per question decides; the set of that attempt is used so
  /// the retry opens where the mistake happened.
  List<MistakeGroup> _mistakes(
    List<SessionResult> results,
    Map<String, QuizSet> sets,
    ContentCatalog catalog,
  ) {
    final latest = <String, (AnswerStatus, String)>{};
    for (final result in results) {
      for (final item in result.items) {
        latest[item.questionId] = (item.status, result.setId);
      }
    }

    final wrongBySet = <String, Set<String>>{};
    for (final MapEntry(key: questionId, value: (status, setId))
        in latest.entries) {
      if (status != AnswerStatus.incorrect && status != AnswerStatus.skipped) {
        continue;
      }
      wrongBySet.putIfAbsent(setId, () => {}).add(questionId);
    }

    return [
      for (final MapEntry(key: setId, value: wrong) in wrongBySet.entries)
        if ((sets[setId], catalog.trackById(sets[setId]?.trackId ?? ''))
            case (final set?, final track?))
          if (set.questionIds.where(wrong.contains).toList()
              case final ids when ids.isNotEmpty)
            MistakeGroup(set: set, track: track, questionIds: ids),
    ]..sort((a, b) {
        final byCount = b.questionIds.length.compareTo(a.questionIds.length);
        return byCount != 0 ? byCount : a.set.id.compareTo(b.set.id);
      });
  }

  /// One entry per available track with a free set, the learner's stack
  /// first. Uses the free set with the most questions.
  List<QuickPractice> _quickPractices(ContentCatalog catalog) {
    final stack = _profileRepository.profile?.techStack ?? const <String>[];
    int rank(String trackId) => stack.contains(trackId) ? 0 : 1;
    final tracks = catalog.availableTracks
      ..sort((a, b) {
        final byStack = rank(a.id).compareTo(rank(b.id));
        return byStack != 0 ? byStack : a.order.compareTo(b.order);
      });

    return [
      for (final track in tracks)
        if (_largestFreeSet(catalog.setsOfTrack(track.id)) case final set?)
          QuickPractice(track: track, set: set),
    ];
  }

  QuizSet? _largestFreeSet(List<QuizSet> sets) {
    QuizSet? best;
    for (final set in sets) {
      if (!set.isFree || set.questionIds.isEmpty) continue;
      if (best == null || set.questionIds.length > best.questionIds.length) {
        best = set;
      }
    }
    return best;
  }
}

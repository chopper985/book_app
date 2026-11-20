// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_repository.dart';

/// The latest result of [setId] that already covered every question about
/// to be practiced, i.e. the learner has completed this practice before.
@injectable
class FindCompletedResult {
  final ContentRepository _contentRepository;
  final PracticeRepository _practiceRepository;

  FindCompletedResult(this._contentRepository, this._practiceRepository);

  /// [onlyQuestionIds] limits the check to a subset (topic practice); by
  /// default every question of the set must have been answered or skipped.
  Future<SessionResult?> call(
    String setId, {
    List<String>? onlyQuestionIds,
  }) async {
    final catalog = (await _contentRepository.loadCatalog()).value;
    List<String>? target = onlyQuestionIds;
    if (target == null) {
      for (final set in catalog?.sets ?? const []) {
        if (set.id == setId) target = set.questionIds;
      }
    }
    if (target == null || target.isEmpty) return null;

    final results = await _practiceRepository.getResults();
    for (final result in results.reversed) {
      if (result.setId != setId) continue;
      final covered = {for (final item in result.items) item.questionId};
      if (target.every(covered.contains)) return result;
    }
    return null;
  }
}

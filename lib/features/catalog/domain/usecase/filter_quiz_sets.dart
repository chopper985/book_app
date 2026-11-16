// Project imports:
import 'package:AppName/features/catalog/domain/entities/quiz_set_summary.dart';
import 'package:AppName/features/content/domain/entities/question.dart';

/// Keeps sets that contain at least one question of the selected topic and
/// level. A `null` filter matches everything.
class FilterQuizSets {
  const FilterQuizSets();

  List<QuizSetSummary> call(
    List<QuizSetSummary> sets, {
    String? topicId,
    QuestionLevel? level,
  }) {
    return sets
        .where(
          (summary) =>
              (topicId == null || summary.topicIds.contains(topicId)) &&
              (level == null || summary.levels.contains(level)),
        )
        .toList();
  }
}

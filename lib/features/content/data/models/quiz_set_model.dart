// Project imports:
import 'package:interview_practice/features/content/data/models/json_reader.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';

class QuizSetModel {
  const QuizSetModel._();

  static QuizSet fromJson(Object? value) {
    final json = JsonReader.from(value, 'set');
    return QuizSet(
      id: json.string('id'),
      trackId: json.string('trackId'),
      title: json.localized('title'),
      questionIds: json.stringList('questionIds'),
      durationMinutes: json.optionalInteger('durationMinutes'),
      accessPlanId: json.optionalString('accessPlanId'),
    );
  }
}

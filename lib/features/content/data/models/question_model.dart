// Project imports:
import 'package:AppName/features/content/data/models/json_reader.dart';
import 'package:AppName/features/content/domain/entities/question.dart';

class QuestionModel {
  const QuestionModel._();

  static Question fromJson(Object? value) {
    final json = JsonReader.from(value, 'question');
    final code = json.json['code'];
    return Question(
      id: json.string('id'),
      contentVersion: json.integer('contentVersion'),
      trackId: json.string('trackId'),
      topicId: json.string('topicId'),
      level: json.enumValue('level', QuestionLevel.values),
      type: json.enumValue('type', QuestionType.values),
      prompt: json.localized('prompt'),
      code: code == null ? null : _codeFromJson(code),
      options: [
        for (final option in json.list('options', optional: true))
          _optionFromJson(option),
      ],
      answerId: json.optionalString('answerId'),
      keyPoints: [
        for (final point in json.list('keyPoints', optional: true))
          JsonReader.parseLocalized(point, 'keyPoints'),
      ],
      explanation: json.localized('explanation', optional: true),
    );
  }

  static CodeSnippet _codeFromJson(Object? value) {
    final json = JsonReader.from(value, 'code');
    return CodeSnippet(
      language: json.string('language'),
      source: json.string('source'),
    );
  }

  static QuestionOption _optionFromJson(Object? value) {
    final json = JsonReader.from(value, 'options');
    return QuestionOption(id: json.string('id'), text: json.localized('text'));
  }
}

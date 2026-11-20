// Project imports:
import 'package:interview_practice/features/content/data/models/json_reader.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';

class PositionModel {
  const PositionModel._();

  static Position fromJson(Object? value) {
    final json = JsonReader.from(value, 'position');
    return Position(
      id: json.string('id'),
      name: json.localized('name'),
      description: json.json['description'] == null
          ? null
          : json.localized('description'),
      options: [
        for (final option in json.list('options')) _optionFromJson(option),
      ],
      coreTrackIds: json.stringList('coreTrackIds'),
    );
  }

  static PositionOption _optionFromJson(Object? value) {
    final json = JsonReader.from(value, 'options');
    return PositionOption(
      id: json.string('id'),
      name: json.localized('name'),
      trackIds: json.stringList('trackIds'),
    );
  }
}

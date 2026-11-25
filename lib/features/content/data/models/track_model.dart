// Project imports:
import 'package:interview_practice/features/content/data/models/json_reader.dart';
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';
import 'package:interview_practice/features/content/domain/entities/track.dart';

class TrackModel {
  const TrackModel._();

  static Track fromJson(Object? value) {
    final json = JsonReader.from(value, 'track');
    return Track(
      id: json.string('id'),
      name: json.localized('name'),
      order: json.integer('order'),
      isAvailable: json.boolean('available'),
      topics: [
        for (final topic in json.list('topics', optional: true))
          _topicFromJson(topic),
      ],
      category: json.optionalString('category'),
      badge: _optionalLocalized(json, 'badge'),
      tagline: _optionalLocalized(json, 'tagline'),
      audience: _optionalLocalized(json, 'audience'),
      languages: _optionalStrings(json, 'languages'),
      runtime: json.optionalString('runtime'),
    );
  }

  static List<String> _optionalStrings(JsonReader json, String key) =>
      json.json[key] == null ? const [] : json.stringList(key);

  static LocalizedText? _optionalLocalized(JsonReader json, String key) =>
      json.json[key] == null ? null : json.localized(key);

  static Topic _topicFromJson(Object? value) {
    final json = JsonReader.from(value, 'topics');
    return Topic(
      id: json.string('id'),
      name: json.localized('name'),
      description: _optionalLocalized(json, 'description'),
      roles: _optionalStrings(json, 'roles'),
    );
  }
}

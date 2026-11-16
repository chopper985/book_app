// Project imports:
import 'package:AppName/features/content/data/models/json_reader.dart';
import 'package:AppName/features/content/domain/entities/localized_text.dart';
import 'package:AppName/features/content/domain/entities/track.dart';

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
    );
  }

  static LocalizedText? _optionalLocalized(JsonReader json, String key) =>
      json.json[key] == null ? null : json.localized(key);

  static Topic _topicFromJson(Object? value) {
    final json = JsonReader.from(value, 'topics');
    return Topic(
      id: json.string('id'),
      name: json.localized('name'),
      description: _optionalLocalized(json, 'description'),
    );
  }
}

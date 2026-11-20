// Project imports:
import 'package:interview_practice/features/content/data/models/content_format_exception.dart';
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';

/// Typed access to a JSON object that reports the failing field.
class JsonReader {
  final Map<String, dynamic> json;

  const JsonReader(this.json);

  factory JsonReader.from(Object? value, String field) {
    if (value is Map<String, dynamic>) return JsonReader(value);
    throw ContentFormatException(field, 'expected an object');
  }

  String string(String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw ContentFormatException(key, 'expected a non-empty string');
  }

  String? optionalString(String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    throw ContentFormatException(key, 'expected a string');
  }

  int integer(String key) {
    final value = json[key];
    if (value is int) return value;
    throw ContentFormatException(key, 'expected an integer');
  }

  int? optionalInteger(String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    throw ContentFormatException(key, 'expected an integer');
  }

  bool boolean(String key, {bool fallback = false}) {
    final value = json[key];
    if (value == null) return fallback;
    if (value is bool) return value;
    throw ContentFormatException(key, 'expected a boolean');
  }

  List<dynamic> list(String key, {bool optional = false}) {
    final value = json[key];
    if (value == null && optional) return const [];
    if (value is List) return value;
    throw ContentFormatException(key, 'expected a list');
  }

  List<String> stringList(String key) => [
        for (final item in list(key))
          if (item is String)
            item
          else
            throw ContentFormatException(key, 'expected a list of strings'),
      ];

  T enumValue<T extends Enum>(String key, List<T> values) {
    final name = string(key);
    for (final value in values) {
      if (value.name == name) return value;
    }
    throw ContentFormatException(
      key,
      'unknown value "$name", expected one of '
      '${values.map((value) => value.name).join(', ')}',
    );
  }

  /// Accepts `{"vi": "...", "en": "..."}` or a plain string for
  /// language-neutral text.
  LocalizedText localized(String key, {bool optional = false}) {
    final value = json[key];
    if (value == null && optional) return const LocalizedText({});
    return parseLocalized(value, key);
  }

  static LocalizedText parseLocalized(Object? value, String field) {
    if (value is String) return LocalizedText.neutral(value);
    if (value is Map<String, dynamic>) {
      final values = <String, String>{};
      for (final MapEntry(:key, value: text) in value.entries) {
        if (text is! String) {
          throw ContentFormatException('$field.$key', 'expected a string');
        }
        values[key] = text;
      }
      return LocalizedText(values);
    }
    throw ContentFormatException(field, 'expected a string or language map');
  }
}

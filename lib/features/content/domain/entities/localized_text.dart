// Package imports:
import 'package:equatable/equatable.dart';

/// Text keyed by language code (`vi`, `en`, ...). Vietnamese is the default
/// language of the content and is required for every text.
class LocalizedText extends Equatable {
  static const String defaultLanguage = 'vi';

  final Map<String, String> values;

  const LocalizedText(this.values);

  /// Language-neutral text such as a code output (`42`, `null`).
  LocalizedText.neutral(String value) : values = {defaultLanguage: value};

  bool hasLanguage(String languageCode) =>
      values[languageCode]?.trim().isNotEmpty ?? false;

  String resolve(String languageCode) {
    if (hasLanguage(languageCode)) return values[languageCode]!;
    if (hasLanguage(defaultLanguage)) return values[defaultLanguage]!;
    return values.values.firstWhere(
      (value) => value.trim().isNotEmpty,
      orElse: () => '',
    );
  }

  @override
  List<Object?> get props => [values];
}

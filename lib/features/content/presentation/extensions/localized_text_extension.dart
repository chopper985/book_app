// Package imports:
import 'package:i18n_extension/i18n_extension.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';

extension LocalizedTextExtension on LocalizedText {
  /// Text in the current app language, falling back to Vietnamese.
  String get text => resolve(I18n.locale.languageCode);
}

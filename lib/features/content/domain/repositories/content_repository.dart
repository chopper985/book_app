// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';

abstract class ContentRepository {
  /// Loads and validates bundled content. Fails with `ContentFailure` when the
  /// data is invalid.
  Future<Result<ContentCatalog>> loadCatalog();
}

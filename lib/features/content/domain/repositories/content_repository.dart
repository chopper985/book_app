// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';

abstract class ContentRepository {
  /// Loads and validates bundled content. Fails with `ContentFailure` when the
  /// data is invalid.
  Future<Result<ContentCatalog>> loadCatalog();
}

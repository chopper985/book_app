// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/content/data/datasources/content_asset_datasource.dart';
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/content_failure.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/content/domain/usecase/validate_content.dart';

@LazySingleton(as: ContentRepository)
class ContentRepositoryImpl implements ContentRepository {
  final ContentAssetDataSource _dataSource;

  ContentRepositoryImpl(this._dataSource);

  /// Bundled content never changes at runtime, so a valid catalog is cached.
  ContentCatalog? _catalog;

  @override
  Future<Result<ContentCatalog>> loadCatalog() async {
    final cached = _catalog;
    if (cached != null) return Result.success(cached);

    final parsed = await const ContentParser().parse(_dataSource.read);
    final issues = [
      ...parsed.issues,
      ...const ValidateContent()(parsed.catalog),
    ];
    if (issues.isNotEmpty) return Result.failure(ContentFailure(issues));

    // Topic sets are generated after validation: they are not authored.
    final catalog = parsed.catalog.withTopicSets();
    _catalog = catalog;
    return Result.success(catalog);
  }
}

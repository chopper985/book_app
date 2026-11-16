// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';

@injectable
class LoadCatalog {
  final ContentRepository _repository;

  LoadCatalog(this._repository);

  Future<Result<ContentCatalog>> call() => _repository.loadCatalog();
}

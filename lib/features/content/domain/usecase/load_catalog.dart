// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';

@injectable
class LoadCatalog {
  final ContentRepository _repository;

  LoadCatalog(this._repository);

  Future<Result<ContentCatalog>> call() => _repository.loadCatalog();
}

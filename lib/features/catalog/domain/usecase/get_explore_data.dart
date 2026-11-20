// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/repositories/catalog_repository.dart';

@injectable
class GetTracks {
  final CatalogRepository _repository;

  GetTracks(this._repository);

  Future<Result<List<TrackOverview>>> call() => _repository.getTracks();
}

@injectable
class GetExploreDashboard {
  final CatalogRepository _repository;

  GetExploreDashboard(this._repository);

  Future<ExploreDashboard> call() => _repository.getDashboard();
}

@injectable
class WatchProgress {
  final CatalogRepository _repository;

  WatchProgress(this._repository);

  Stream<void> call() => _repository.progressChanges;
}

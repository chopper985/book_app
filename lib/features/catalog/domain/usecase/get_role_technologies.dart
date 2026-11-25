// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/role_technologies.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/domain/repositories/catalog_repository.dart';

/// Technologies grouped by position, from `positions.json`. Unavailable or
/// unknown tracks are left out; positions without any track are skipped.
@injectable
class GetRoleTechnologies {
  final CatalogRepository _repository;

  GetRoleTechnologies(this._repository);

  Future<List<RoleTechnologies>> call() async {
    final positions = (await _repository.getPositions()).value;
    final tracks = (await _repository.getTracks()).value;
    if (positions == null || tracks == null) return const [];
    final byId = <String, TrackOverview>{
      for (final overview in tracks)
        if (overview.track.isAvailable) overview.track.id: overview,
    };

    List<TrackOverview> resolve(Iterable<String> ids) => [
          for (final id in ids.toSet())
            if (byId[id] case final overview?) overview,
        ];

    final result = <RoleTechnologies>[];
    for (final position in positions) {
      final main = resolve(position.options.expand((o) => o.trackIds));
      final mainIds = {for (final overview in main) overview.track.id};
      final shared = resolve(
        position.coreTrackIds.where((id) => !mainIds.contains(id)),
      );
      if (main.isEmpty && shared.isEmpty) continue;
      result.add(
        RoleTechnologies(position: position, main: main, shared: shared),
      );
    }
    return result;
  }
}

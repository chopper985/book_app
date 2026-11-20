// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/features/catalog/data/datasources/user_roadmaps_local_datasource.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/catalog/domain/repositories/user_roadmaps_repository.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

@LazySingleton(as: UserRoadmapsRepository)
class UserRoadmapsRepositoryImpl implements UserRoadmapsRepository {
  final UserRoadmapsLocalDataSource _local;
  final AppClock _clock;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  UserRoadmapsRepositoryImpl(this._local, this._clock);

  @override
  List<UserRoadmap> get roadmaps => _local.read().roadmaps;

  @override
  UserRoadmap? get active {
    final data = _local.read();
    for (final roadmap in data.roadmaps) {
      if (roadmap.id == data.activeId) return roadmap;
    }
    return data.roadmaps.firstOrNull;
  }

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<UserRoadmap> add(String trackId, QuestionLevel level) => _addOrReuse(
        UserRoadmap(trackId: trackId, level: level, addedAt: _clock.now()),
      );

  @override
  Future<UserRoadmap> addPosition({
    required String positionId,
    required String optionId,
    required String mainTrackId,
    required QuestionLevel level,
  }) =>
      _addOrReuse(
        UserRoadmap(
          trackId: mainTrackId,
          level: level,
          addedAt: _clock.now(),
          positionId: positionId,
          optionId: optionId,
        ),
      );

  /// Moves an existing roadmap with the same id to the top instead of
  /// adding a duplicate, and makes it active.
  Future<UserRoadmap> _addOrReuse(UserRoadmap candidate) async {
    final id = candidate.id;
    final current = _local.read().roadmaps;
    final roadmap = current.where((r) => r.id == id).firstOrNull ?? candidate;
    await _save([roadmap, ...current.where((r) => r.id != id)], id);
    return roadmap;
  }

  @override
  Future<void> select(String roadmapId) async {
    final current = _local.read().roadmaps;
    final selected = current.where((r) => r.id == roadmapId).firstOrNull;
    if (selected == null) return;
    // Most recently selected first, so every fallback (app start without a
    // readable active id, removing the active one, opening a track from
    // Explore) lands on the roadmap used last.
    await _save(
      [selected, ...current.where((r) => r.id != roadmapId)],
      roadmapId,
    );
  }

  @override
  Future<void> remove(String roadmapId) async {
    final data = _local.read();
    final remaining = data.roadmaps.where((r) => r.id != roadmapId).toList();
    final activeId =
        data.activeId == roadmapId ? remaining.firstOrNull?.id : data.activeId;
    await _save(remaining, activeId);
  }

  Future<void> _save(List<UserRoadmap> roadmaps, String? activeId) async {
    await _local.write((roadmaps: roadmaps, activeId: activeId));
    _changes.add(null);
  }
}

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/features/catalog/data/datasources/user_roadmaps_local_datasource.dart';
import 'package:AppName/features/catalog/domain/entities/user_roadmap.dart';
import 'package:AppName/features/catalog/domain/repositories/user_roadmaps_repository.dart';
import 'package:AppName/features/content/domain/entities/question.dart';

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
  Future<UserRoadmap> add(String trackId, QuestionLevel level) async {
    final id = UserRoadmap.idOf(trackId, level);
    final current = _local.read().roadmaps;
    final existing = current.where((r) => r.id == id).firstOrNull;
    final roadmap = existing ??
        UserRoadmap(trackId: trackId, level: level, addedAt: _clock.now());
    await _save([roadmap, ...current.where((r) => r.id != id)], id);
    return roadmap;
  }

  @override
  Future<void> select(String roadmapId) async {
    final current = _local.read().roadmaps;
    if (current.any((r) => r.id == roadmapId)) {
      await _save(current, roadmapId);
    }
  }

  @override
  Future<void> remove(String roadmapId) async {
    final data = _local.read();
    final remaining = data.roadmaps.where((r) => r.id != roadmapId).toList();
    final activeId = data.activeId == roadmapId
        ? remaining.firstOrNull?.id
        : data.activeId;
    await _save(remaining, activeId);
  }

  Future<void> _save(List<UserRoadmap> roadmaps, String? activeId) async {
    await _local.write((roadmaps: roadmaps, activeId: activeId));
    _changes.add(null);
  }
}

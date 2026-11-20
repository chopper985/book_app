// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/data/datasources/saved_tracks_local_datasource.dart';
import 'package:interview_practice/features/catalog/domain/repositories/saved_tracks_repository.dart';

@LazySingleton(as: SavedTracksRepository)
class SavedTracksRepositoryImpl extends SavedTracksRepository {
  final SavedTracksLocalDataSource _local;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  SavedTracksRepositoryImpl(this._local);

  @override
  List<String> get savedTrackIds => _local.read();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> toggle(String trackId) async {
    final ids = [..._local.read()];
    if (!ids.remove(trackId)) ids.insert(0, trackId);
    await _local.write(ids);
    _changes.add(null);
  }
}

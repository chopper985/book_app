// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/repositories/saved_tracks_repository.dart';

@injectable
class GetSavedTrackIds {
  final SavedTracksRepository _repository;

  GetSavedTrackIds(this._repository);

  List<String> call() => _repository.savedTrackIds;
}

@injectable
class ToggleSavedTrack {
  final SavedTracksRepository _repository;

  ToggleSavedTrack(this._repository);

  Future<void> call(String trackId) => _repository.toggle(trackId);
}

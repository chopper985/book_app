abstract class SavedTracksRepository {
  /// Saved track ids, most recently saved first.
  List<String> get savedTrackIds;

  bool isSaved(String trackId) => savedTrackIds.contains(trackId);

  /// Saves the track, or removes it when already saved.
  Future<void> toggle(String trackId);

  /// Replaces the whole list (cloud sync, sign-out).
  Future<void> replaceAll(List<String> trackIds);

  /// Fires after the saved list changes.
  Stream<void> get changes;
}

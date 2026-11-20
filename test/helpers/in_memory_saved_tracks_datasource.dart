// Project imports:
import 'package:AppName/features/catalog/data/datasources/saved_tracks_local_datasource.dart';

class InMemorySavedTracksLocalDataSource implements SavedTracksLocalDataSource {
  List<String> ids = const [];

  @override
  List<String> read() => ids;

  @override
  Future<void> write(List<String> trackIds) async => ids = List.of(trackIds);
}

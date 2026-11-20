// Project imports:
import 'package:AppName/features/profile/data/datasources/avatar_local_datasource.dart';

/// Records stored avatars by name instead of copying files.
class InMemoryAvatarLocalDataSource implements AvatarLocalDataSource {
  final Map<String, String> files = {};
  int _next = 0;

  @override
  Future<String> store(String sourcePath) async {
    final name = 'avatar_${_next++}.jpg';
    files[name] = sourcePath;
    return name;
  }

  @override
  Future<String?> pathOf(String fileName) async =>
      files.containsKey(fileName) ? '/avatars/$fileName' : null;

  @override
  Future<void> prune({String? keep}) async =>
      files.removeWhere((name, _) => name != keep);
}

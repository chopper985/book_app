// Dart imports:
import 'dart:io';

// Package imports:
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// Avatar images in `<app documents>/avatars`. Only the newest file is kept.
abstract class AvatarLocalDataSource {
  /// Copies [sourcePath] in and returns the new file name.
  Future<String> store(String sourcePath);

  Future<String?> pathOf(String fileName);

  /// Deletes every avatar except [keep].
  Future<void> prune({String? keep});
}

@LazySingleton(as: AvatarLocalDataSource)
class FileAvatarLocalDataSource implements AvatarLocalDataSource {
  Future<Directory> _dir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/avatars');
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<String> store(String sourcePath) async {
    final dir = await _dir();
    final dot = sourcePath.lastIndexOf('.');
    final extension =
        dot < 0 ? '.jpg' : sourcePath.substring(dot).toLowerCase();
    final name = 'avatar_${DateTime.now().microsecondsSinceEpoch}$extension';
    await File(sourcePath).copy('${dir.path}/$name');
    return name;
  }

  @override
  Future<String?> pathOf(String fileName) async {
    final file = File('${(await _dir()).path}/$fileName');
    return file.existsSync() ? file.path : null;
  }

  @override
  Future<void> prune({String? keep}) async {
    final dir = await _dir();
    for (final entity in dir.listSync()) {
      if (entity is File && entity.uri.pathSegments.last != keep) {
        await entity.delete();
      }
    }
  }
}

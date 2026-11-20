// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/constants/storage_key.dart';

abstract class SavedTracksLocalDataSource {
  List<String> read();

  Future<void> write(List<String> trackIds);
}

/// One JSON list of track ids.
@LazySingleton(as: SavedTracksLocalDataSource)
class HiveSavedTracksLocalDataSource implements SavedTracksLocalDataSource {
  static const String _key = 'ids';

  Box<String> get _box => Hive.box<String>(StorageKeys.savedTracksBox);

  @override
  List<String> read() {
    final raw = _box.get(_key);
    if (raw == null) return const [];
    try {
      return List<String>.unmodifiable(jsonDecode(raw) as List);
    } catch (error) {
      debugPrint('Unreadable saved tracks: $error');
      return const [];
    }
  }

  @override
  Future<void> write(List<String> trackIds) =>
      _box.put(_key, jsonEncode(trackIds));
}

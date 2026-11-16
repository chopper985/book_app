// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:injectable/injectable.dart';

@lazySingleton
class ContentAssetDataSource {
  static const String root = 'assets/content';

  /// Returns the file content, or `null` when the asset is not bundled.
  Future<String?> read(String relativePath) async {
    try {
      return await rootBundle.loadString('$root/$relativePath', cache: false);
    } on FlutterError {
      return null;
    }
  }
}

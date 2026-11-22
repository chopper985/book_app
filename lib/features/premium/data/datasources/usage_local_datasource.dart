// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/constants/storage_key.dart';

abstract class UsageLocalDataSource {
  /// Sessions per local day, keyed `yyyy-MM-dd`.
  Map<String, int> readDays();

  Future<void> writeDays(Map<String, int> days);

  int readExtraUsed();

  Future<void> writeExtraUsed(int value);
}

@LazySingleton(as: UsageLocalDataSource)
class HiveUsageLocalDataSource implements UsageLocalDataSource {
  static const String _daysKey = 'days';
  static const String _extraKey = 'extraUsed';

  Box<String> get _box => Hive.box<String>(StorageKeys.practiceUsageBox);

  @override
  Map<String, int> readDays() {
    final raw = _box.get(_daysKey);
    if (raw == null) return const {};
    try {
      return Map<String, int>.from(jsonDecode(raw) as Map);
    } catch (error) {
      debugPrint('Unreadable practice usage: $error');
      return const {};
    }
  }

  @override
  Future<void> writeDays(Map<String, int> days) =>
      _box.put(_daysKey, jsonEncode(days));

  @override
  int readExtraUsed() => int.tryParse(_box.get(_extraKey) ?? '') ?? 0;

  @override
  Future<void> writeExtraUsed(int value) => _box.put(_extraKey, '$value');
}

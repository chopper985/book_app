// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/premium/data/datasources/usage_local_datasource.dart';
import 'package:interview_practice/features/premium/domain/repositories/usage_repository.dart';

@LazySingleton(as: UsageRepository)
class UsageRepositoryImpl implements UsageRepository {
  /// Days kept, enough for the daily limit.
  static const int keptDays = 7;

  final UsageLocalDataSource _local;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  UsageRepositoryImpl(this._local);

  static String dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  int usedOn(DateTime day) => _local.readDays()[dayKey(day)] ?? 0;

  @override
  int get extraSessionsUsed => _local.readExtraUsed();

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<void> recordDailyUse(DateTime day) async {
    final key = dayKey(day);
    final days = {..._local.readDays()};
    days[key] = (days[key] ?? 0) + 1;
    final oldestFirst = days.keys.toList()..sort();
    for (var i = 0; i < oldestFirst.length - keptDays; i++) {
      days.remove(oldestFirst[i]);
    }
    await _local.writeDays(days);
    _changes.add(null);
  }

  @override
  Future<void> recordExtraUse() async {
    await _local.writeExtraUsed(_local.readExtraUsed() + 1);
    _changes.add(null);
  }

  @override
  Future<void> restoreExtraSessionsUsed(int value) async {
    if (value == _local.readExtraUsed()) return;
    await _local.writeExtraUsed(value < 0 ? 0 : value);
    _changes.add(null);
  }
}

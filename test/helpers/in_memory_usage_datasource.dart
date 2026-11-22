// Project imports:
import 'package:interview_practice/features/premium/data/datasources/usage_local_datasource.dart';

class InMemoryUsageLocalDataSource implements UsageLocalDataSource {
  Map<String, int> days = {};
  int extraUsed = 0;

  @override
  Map<String, int> readDays() => days;

  @override
  Future<void> writeDays(Map<String, int> value) async => days = {...value};

  @override
  int readExtraUsed() => extraUsed;

  @override
  Future<void> writeExtraUsed(int value) async => extraUsed = value;
}

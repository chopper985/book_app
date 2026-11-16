// Package imports:
import 'package:injectable/injectable.dart';

/// Wraps `DateTime.now` so time-based logic can be tested.
@lazySingleton
class AppClock {
  DateTime now() => DateTime.now();
}

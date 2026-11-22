// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/premium/domain/entities/practice_quota.dart';
import 'package:interview_practice/features/premium/domain/usecase/practice_access.dart';

/// The learner's plan and remaining sessions, app-wide.
@injectable
class QuotaCubit extends Cubit<PracticeQuota> {
  final PracticeAccess _access;
  StreamSubscription<PracticeQuota>? _subscription;

  QuotaCubit(this._access) : super(_access.quota) {
    _subscription = _access.changes.listen(emit);
  }

  /// Recomputes "today" (e.g. when the Profile tab opens after midnight).
  void refresh() => emit(_access.quota);

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

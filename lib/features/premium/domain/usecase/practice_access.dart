// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_gate.dart';
import 'package:interview_practice/features/premium/domain/entities/practice_quota.dart';
import 'package:interview_practice/features/premium/domain/repositories/purchase_repository.dart';
import 'package:interview_practice/features/premium/domain/repositories/usage_repository.dart';

/// Plan rules: Free has 3 sessions a day, Premium 10 a day and the
/// Middle/Senior sets; bought extra sessions are used once the day's
/// allowance is gone and never unlock Middle/Senior.
@lazySingleton
class PracticeAccess implements PracticeGate {
  final PurchaseRepository _purchases;
  final UsageRepository _usage;
  final ContentRepository _content;
  final AppClock _clock;

  PracticeAccess(this._purchases, this._usage, this._content, this._clock);

  PracticeQuota get quota {
    final status = _purchases.status;
    return PracticeQuota(
      isPremium: status.isPremium,
      premiumExpiresAt: status.premiumExpiresAt,
      usedToday: _usage.usedOn(_clock.now()),
      extraSessions:
          max(0, status.purchasedSessions - _usage.extraSessionsUsed),
    );
  }

  StreamController<PracticeQuota>? _controller;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  /// Emits the quota whenever purchases or usage change.
  Stream<PracticeQuota> get changes {
    _controller ??= StreamController<PracticeQuota>.broadcast(
      onListen: () {
        void emit(Object? _) => _controller?.add(quota);
        _subscriptions
          ..add(_purchases.statusChanges.listen(emit))
          ..add(_usage.changes.listen(emit));
      },
      onCancel: _cancelSources,
    );
    return _controller!.stream;
  }

  Future<void> _cancelSources() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  Future<void> dispose() async {
    await _cancelSources();
    await _controller?.close();
    _controller = null;
  }

  @override
  Future<PracticeDenial?> check(String setId) async {
    final set = await _set(setId);
    final current = quota;
    if (set != null && !set.isFree && !current.isPremium) {
      return PracticeDenial.premiumLevel;
    }
    return current.canStart ? null : PracticeDenial.quotaExhausted;
  }

  @override
  Future<void> consume() async {
    final current = quota;
    if (current.remainingToday > 0) {
      await _usage.recordDailyUse(_clock.now());
    } else if (current.extraSessions > 0) {
      await _usage.recordExtraUse();
    }
  }

  Future<QuizSet?> _set(String setId) async {
    final catalog = (await _content.loadCatalog()).value;
    if (catalog == null) return null;
    for (final set in catalog.sets) {
      if (set.id == setId) return set;
    }
    return null;
  }
}

/// The practice feature only sees the [PracticeGate] side of the rules.
@module
abstract class PracticeGateModule {
  @lazySingleton
  PracticeGate gate(PracticeAccess access) => access;
}

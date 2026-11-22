// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/core/error/failure.dart';

/// What the store says the learner owns.
class StoreStatus extends Equatable {
  final bool isPremium;
  final DateTime? premiumExpiresAt;

  /// Extra sessions bought over the account's lifetime.
  final int purchasedSessions;

  const StoreStatus({
    this.isPremium = false,
    this.premiumExpiresAt,
    this.purchasedSessions = 0,
  });

  static const StoreStatus none = StoreStatus();

  @override
  List<Object?> get props => [isPremium, premiumExpiresAt, purchasedSessions];
}

enum StorePackageKind { monthly, annual, sessions }

/// A product the paywall can sell, with the store's localized price.
class StorePackage extends Equatable {
  final String id;
  final StorePackageKind kind;
  final String price;

  /// Sessions added by a [StorePackageKind.sessions] pack.
  final int sessions;

  const StorePackage({
    required this.id,
    required this.kind,
    required this.price,
    this.sessions = 0,
  });

  @override
  List<Object?> get props => [id, kind, price, sessions];
}

enum PurchaseFailureCode {
  notConfigured,
  network,
  notAllowed,
  pending,
  unknown
}

class PurchaseFailure extends Failure {
  final PurchaseFailureCode code;

  /// Store message, for logs only.
  final String? detail;

  PurchaseFailure(this.code, [this.detail]);

  @override
  List<Object> get props => [code, detail ?? ''];
}

sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

final class PurchaseCompleted extends PurchaseOutcome {
  final StoreStatus status;

  const PurchaseCompleted(this.status);
}

final class PurchaseCancelled extends PurchaseOutcome {
  const PurchaseCancelled();
}

final class PurchaseFailed extends PurchaseOutcome {
  final PurchaseFailure failure;

  const PurchaseFailed(this.failure);
}

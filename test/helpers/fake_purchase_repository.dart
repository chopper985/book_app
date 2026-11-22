// Dart imports:
import 'dart:async';

// Project imports:
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';
import 'package:interview_practice/features/premium/domain/repositories/purchase_repository.dart';

const StorePackage monthlyPackage = StorePackage(
  id: r'$rc_monthly',
  kind: StorePackageKind.monthly,
  price: '99.000 ₫',
);
const StorePackage annualPackage = StorePackage(
  id: r'$rc_annual',
  kind: StorePackageKind.annual,
  price: '799.000 ₫',
);
const StorePackage sessionsPackage = StorePackage(
  id: 'sessions_10',
  kind: StorePackageKind.sessions,
  price: '29.000 ₫',
  sessions: 10,
);

/// Scriptable store: purchases succeed and update [status].
class FakePurchaseRepository implements PurchaseRepository {
  final StreamController<StoreStatus> _changes =
      StreamController<StoreStatus>.broadcast();

  @override
  bool isConfigured = true;
  StoreStatus _status = StoreStatus.none;
  List<StorePackage> available = const [
    monthlyPackage,
    annualPackage,
    sessionsPackage,
  ];
  PurchaseOutcome? nextOutcome;
  final List<String> identified = [];

  @override
  StoreStatus get status => _status;

  set status(StoreStatus value) {
    _status = value;
    _changes.add(value);
  }

  @override
  Stream<StoreStatus> get statusChanges => _changes.stream;

  @override
  Future<void> identify(String uid) async => identified.add(uid);

  @override
  Future<List<StorePackage>> packages() async => available;

  @override
  Future<PurchaseOutcome> purchase(StorePackage package) async {
    final scripted = nextOutcome;
    if (scripted != null) return scripted;
    status = package.kind == StorePackageKind.sessions
        ? StoreStatus(
            isPremium: _status.isPremium,
            premiumExpiresAt: _status.premiumExpiresAt,
            purchasedSessions: _status.purchasedSessions + package.sessions,
          )
        : StoreStatus(
            isPremium: true,
            premiumExpiresAt: DateTime(2026, 12, 20),
            purchasedSessions: _status.purchasedSessions,
          );
    return PurchaseCompleted(_status);
  }

  @override
  Future<PurchaseOutcome> restore() async =>
      nextOutcome ?? PurchaseCompleted(_status);
}

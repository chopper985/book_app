// Dart imports:
import 'dart:async';

// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/domain/repositories/auth_repository.dart';
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';
import 'package:interview_practice/features/premium/domain/repositories/purchase_repository.dart';

@injectable
class LoadStorePackages {
  final PurchaseRepository _repository;

  LoadStorePackages(this._repository);

  Future<List<StorePackage>> call() => _repository.packages();
}

@injectable
class PurchasePackage {
  final PurchaseRepository _repository;

  PurchasePackage(this._repository);

  Future<PurchaseOutcome> call(StorePackage package) =>
      _repository.purchase(package);
}

@injectable
class RestorePurchases {
  final PurchaseRepository _repository;

  RestorePurchases(this._repository);

  Future<PurchaseOutcome> call() => _repository.restore();
}

/// Logs the store in as the current Firebase account (anonymous included),
/// so purchases move along when the account is linked or switched.
@lazySingleton
class PurchaseIdentity {
  final AuthRepository _auth;
  final PurchaseRepository _purchases;
  StreamSubscription<AuthUser?>? _subscription;

  PurchaseIdentity(this._auth, this._purchases);

  void start() {
    final current = _auth.currentUser;
    if (current != null) unawaited(_purchases.identify(current.uid));
    _subscription ??= _auth.userChanges.listen((user) {
      if (user != null) unawaited(_purchases.identify(user.uid));
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

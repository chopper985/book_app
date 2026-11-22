// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import 'package:interview_practice/core/constants/revenuecat_config.dart';
import 'package:interview_practice/features/premium/domain/entities/practice_quota.dart';
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';
import 'package:interview_practice/features/premium/domain/repositories/purchase_repository.dart';

/// RevenueCat: the `premium` entitlement (monthly / yearly subscriptions)
/// and consumable extra-session packs, counted from the account's
/// non-subscription transactions.
@LazySingleton(as: PurchaseRepository)
class RevenueCatPurchaseRepository implements PurchaseRepository {
  final StreamController<StoreStatus> _changes =
      StreamController<StoreStatus>.broadcast();
  final Map<String, Package> _packages = {};
  StoreStatus _status = StoreStatus.none;
  Future<void>? _configuring;
  String? _uid;

  String get _apiKey {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return RevenueCatConfig.androidApiKey;
    if (Platform.isIOS) return RevenueCatConfig.iosApiKey;
    return '';
  }

  @override
  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  StoreStatus get status => _status;

  @override
  Stream<StoreStatus> get statusChanges => _changes.stream;

  @override
  Future<void> identify(String uid) async {
    if (!isConfigured || uid == _uid) return;
    try {
      if (_configuring == null) {
        _uid = uid;
        _configuring = _configure(uid);
        await _configuring;
        return;
      }
      await _configuring;
      if (uid == _uid) return;
      _uid = uid;
      final result = await Purchases.logIn(uid);
      _update(result.customerInfo);
    } on PlatformException catch (error) {
      debugPrint('RevenueCat identify failed: ${error.message}');
    }
  }

  Future<void> _configure(String uid) async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    await Purchases.configure(PurchasesConfiguration(_apiKey)..appUserID = uid);
    Purchases.addCustomerInfoUpdateListener(_update);
    _update(await Purchases.getCustomerInfo());
  }

  @override
  Future<List<StorePackage>> packages() async {
    if (!await _ready()) return const [];
    try {
      final offering = (await Purchases.getOfferings()).current;
      if (offering == null) return const [];
      _packages.clear();
      final result = <StorePackage>[];
      for (final package in offering.availablePackages) {
        final kind = switch (package.packageType) {
          PackageType.monthly => StorePackageKind.monthly,
          PackageType.annual => StorePackageKind.annual,
          _ => _sessionsIn(package.storeProduct.identifier) > 0
              ? StorePackageKind.sessions
              : null,
        };
        if (kind == null) continue;
        _packages[package.identifier] = package;
        result.add(
          StorePackage(
            id: package.identifier,
            kind: kind,
            price: package.storeProduct.priceString,
            sessions: kind == StorePackageKind.sessions
                ? _sessionsIn(package.storeProduct.identifier)
                : 0,
          ),
        );
      }
      return result;
    } on PlatformException catch (error) {
      debugPrint('RevenueCat offerings failed: ${error.message}');
      return const [];
    }
  }

  @override
  Future<PurchaseOutcome> purchase(StorePackage package) async {
    final native = _packages[package.id];
    if (!await _ready() || native == null) {
      return PurchaseFailed(PurchaseFailure(PurchaseFailureCode.notConfigured));
    }
    try {
      final result = await Purchases.purchase(PurchaseParams.package(native));
      return PurchaseCompleted(_update(result.customerInfo));
    } on PlatformException catch (error) {
      return _failureOf(error);
    }
  }

  @override
  Future<PurchaseOutcome> restore() async {
    if (!await _ready()) {
      return PurchaseFailed(PurchaseFailure(PurchaseFailureCode.notConfigured));
    }
    try {
      return PurchaseCompleted(_update(await Purchases.restorePurchases()));
    } on PlatformException catch (error) {
      return _failureOf(error);
    }
  }

  Future<bool> _ready() async {
    if (!isConfigured || _configuring == null) return false;
    try {
      await _configuring;
      return true;
    } on PlatformException {
      return false;
    }
  }

  StoreStatus _update(CustomerInfo info) {
    final premium =
        info.entitlements.active[RevenueCatConfig.premiumEntitlementId];
    final purchased = info.nonSubscriptionTransactions.fold<int>(
      0,
      (sum, transaction) => sum + _sessionsIn(transaction.productIdentifier),
    );
    final status = StoreStatus(
      isPremium: premium != null,
      premiumExpiresAt: premium?.expirationDate == null
          ? null
          : DateTime.tryParse(premium!.expirationDate!)?.toLocal(),
      purchasedSessions: purchased,
    );
    if (status != _status) {
      _status = status;
      _changes.add(status);
    }
    return status;
  }

  /// Extra sessions in a consumable product: the number in its id
  /// (`practice_sessions_10`), or the default for other `sessions` ids.
  static int _sessionsIn(String productId) {
    final id = productId.toLowerCase();
    if (!id.contains('session')) return 0;
    final match = RegExp(r'(\d+)').firstMatch(id);
    return int.tryParse(match?.group(1) ?? '') ??
        PremiumPlans.defaultPackSessions;
  }

  static PurchaseOutcome _failureOf(PlatformException error) {
    final code = PurchasesErrorHelper.getErrorCode(error);
    return switch (code) {
      PurchasesErrorCode.purchaseCancelledError => const PurchaseCancelled(),
      PurchasesErrorCode.networkError =>
        PurchaseFailed(PurchaseFailure(PurchaseFailureCode.network)),
      PurchasesErrorCode.purchaseNotAllowedError ||
      PurchasesErrorCode.insufficientPermissionsError =>
        PurchaseFailed(PurchaseFailure(PurchaseFailureCode.notAllowed)),
      PurchasesErrorCode.paymentPendingError =>
        PurchaseFailed(PurchaseFailure(PurchaseFailureCode.pending)),
      PurchasesErrorCode.configurationError ||
      PurchasesErrorCode.invalidCredentialsError ||
      PurchasesErrorCode.productNotAvailableForPurchaseError =>
        PurchaseFailed(
          PurchaseFailure(PurchaseFailureCode.notConfigured, error.message),
        ),
      _ => PurchaseFailed(
          PurchaseFailure(PurchaseFailureCode.unknown, error.message),
        ),
    };
  }
}

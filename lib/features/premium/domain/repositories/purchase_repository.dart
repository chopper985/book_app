// Project imports:
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';

/// In-app purchases (RevenueCat).
abstract class PurchaseRepository {
  /// `false` when no store key is set for this platform.
  bool get isConfigured;

  StoreStatus get status;

  Stream<StoreStatus> get statusChanges;

  /// Ties purchases to the Firebase account so they follow the learner.
  Future<void> identify(String uid);

  /// Monthly, yearly and extra-session packages of the current offering.
  Future<List<StorePackage>> packages();

  Future<PurchaseOutcome> purchase(StorePackage package);

  /// Restores purchases made with the same store account.
  Future<PurchaseOutcome> restore();
}

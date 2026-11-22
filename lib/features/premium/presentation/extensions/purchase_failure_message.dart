// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';

extension PurchaseFailureMessage on PurchaseFailure {
  String get message => switch (code) {
        PurchaseFailureCode.notConfigured => Strings.premiumNotReady,
        PurchaseFailureCode.network => Strings.premiumErrorNetwork,
        PurchaseFailureCode.notAllowed => Strings.premiumErrorNotAllowed,
        PurchaseFailureCode.pending => Strings.premiumErrorPending,
        PurchaseFailureCode.unknown => Strings.premiumErrorUnknown,
      }
          .i18n;
}

/// `dd/MM/yyyy`, for plan expiry dates.
String formatPlanDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

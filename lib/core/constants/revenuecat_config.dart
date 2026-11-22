/// RevenueCat project settings (RevenueCat dashboard > Project > API keys).
/// Public SDK keys are meant to ship in the app; leave a key empty to turn
/// purchases off on that platform (the paywall then says the store is not
/// ready). Never put the secret `sk_` key here.
class RevenueCatConfig {
  const RevenueCatConfig._();

  /// Google Play public SDK key, starts with `goog_`.
  static const String androidApiKey = '';

  /// App Store public SDK key, starts with `appl_`.
  static const String iosApiKey = '';

  /// Entitlement that unlocks Premium (monthly and yearly products).
  static const String premiumEntitlementId = 'premium';
}

/// Turns what a learner types into E.164 for Firebase. Vietnamese numbers
/// are the default: `0912 345 678`, `912345678` and `+84 912 345 678` all
/// become `+84912345678`. Returns `null` when it cannot be a phone number.
class NormalizePhoneNumber {
  const NormalizePhoneNumber();

  static const String defaultCountryCode = '84';

  String? call(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    if (!RegExp(r'^\+?[0-9 ().\-]+$').hasMatch(trimmed)) return null;
    var digits = trimmed.replaceAll(RegExp('[^0-9]'), '');

    if (trimmed.startsWith('+')) {
      return _valid(digits) ? '+$digits' : null;
    }
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
      return _valid(digits) ? '+$digits' : null;
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.startsWith(defaultCountryCode) && digits.length > 10) {
      return _valid(digits) ? '+$digits' : null;
    }
    // Vietnamese mobile numbers have 9 digits after the trunk 0.
    if (digits.length != 9) return null;
    return '+$defaultCountryCode$digits';
  }

  /// E.164: up to 15 digits including the country code.
  bool _valid(String digits) => digits.length >= 8 && digits.length <= 15;
}

/// Rules for Bolivian mobile numbers, shared by the registration and by
/// sending receipts through WhatsApp.
abstract final class BolivianPhoneNumber {
  static const String countryCode = '591';

  /// Mobile numbers have 8 digits and start with 6 or 7.
  static final RegExp _mobilePattern = RegExp(r'^[67]\d{7}$');

  /// Keeps only the digits and drops a leading country code.
  static String normalize(String input) {
    final String digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11 && digits.startsWith(countryCode)) {
      return digits.substring(countryCode.length);
    }
    return digits;
  }

  static bool isValidMobile(String input) =>
      _mobilePattern.hasMatch(normalize(input));

  /// `59176543210`, the format WhatsApp links expect.
  static String toInternational(String input) =>
      '$countryCode${normalize(input)}';
}

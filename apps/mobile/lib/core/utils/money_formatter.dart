import 'package:intl/intl.dart';

/// Formats amounts as Bolivian bolivianos using the `es-BO` convention
/// (`.` for thousands, `,` for decimals): `Bs 2.345,00`.
abstract final class MoneyFormatter {
  static const String currencySymbol = 'Bs';
  static const String _locale = 'es_BO';

  static final NumberFormat _decimal = NumberFormat.currency(
    locale: _locale,
    symbol: '',
    decimalDigits: 2,
  );
  static final NumberFormat _integer = NumberFormat.decimalPattern(_locale)
    ..maximumFractionDigits = 0;

  /// `Bs 2.345,00`
  static String format(double amount) =>
      '$currencySymbol ${amountOnly(amount)}';

  /// `2.345,00` — for inputs and custom layouts that render `Bs` separately.
  static String amountOnly(double amount) => _decimal.format(amount).trim();

  /// `Bs 2.345` — compact variant for chips and dense rows.
  static String formatCompact(double amount) =>
      '$currencySymbol ${_integer.format(amount)}';

  /// `36,8 %`
  static String formatPercent(double ratio, {int decimals = 1}) {
    final NumberFormat format = NumberFormat.decimalPattern(_locale)
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return '${format.format(ratio * 100)} %';
  }

  /// Parses user input that may use either decimal separator.
  static double? tryParse(String input) {
    final String cleaned = input
        .replaceAll(currencySymbol, '')
        .replaceAll(' ', '')
        .trim();
    if (cleaned.isEmpty) return null;

    // `1.234,56` uses `.` for thousands; a lone `.` or `,` is the decimal
    // separator, because numeric keyboards offer only one of them.
    final bool hasComma = cleaned.contains(',');
    final bool hasDot = cleaned.contains('.');
    final String normalized;
    if (hasComma && hasDot) {
      normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma) {
      normalized = cleaned.replaceAll(',', '.');
    } else {
      normalized = cleaned;
    }

    return double.tryParse(normalized);
  }
}

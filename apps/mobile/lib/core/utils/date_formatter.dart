import 'package:intl/intl.dart';

/// Spanish (Bolivia) date and time formatting helpers.
abstract final class DateFormatter {
  static const String _locale = 'es';

  /// `Miércoles 16 de septiembre`
  static String longDate(DateTime date) =>
      _capitalize(DateFormat("EEEE d 'de' MMMM", _locale).format(date));

  /// `Mié 16 sep`
  static String shortDate(DateTime date) =>
      _capitalize(DateFormat('E d MMM', _locale).format(date))
          .replaceAll('.', '');

  /// `16 sep`
  static String dayMonth(DateTime date) =>
      DateFormat('d MMM', _locale).format(date).replaceAll('.', '');

  /// `08:30`
  static String time(DateTime date) => DateFormat.Hm(_locale).format(date);

  /// `16/09/2026 · 11:24`
  static String receiptStamp(DateTime date) =>
      '${DateFormat('dd/MM/yyyy', _locale).format(date)} · ${time(date)}';

  /// `Mié 16 sep · 08:30`
  static String shortDateTime(DateTime date) =>
      '${shortDate(date)} · ${time(date)}';

  /// `11 h 15 min`
  static String duration(Duration value) {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    if (hours == 0) return '$minutes min';
    return '$hours h $minutes min';
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

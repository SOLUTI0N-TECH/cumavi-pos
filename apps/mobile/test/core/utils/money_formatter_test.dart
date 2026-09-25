import 'package:cumavi_pos_mobile/core/utils/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  group('MoneyFormatter', () {
    test('formats with the Bolivian convention', () {
      expect(MoneyFormatter.format(2345), 'Bs 2.345,00');
      expect(MoneyFormatter.format(813.5), 'Bs 813,50');
      expect(MoneyFormatter.format(0), 'Bs 0,00');
    });

    test('formats compact amounts without decimals', () {
      expect(MoneyFormatter.formatCompact(1405), 'Bs 1.405');
    });

    test('formats percentages', () {
      expect(MoneyFormatter.formatPercent(0.368), '36,8 %');
      expect(MoneyFormatter.formatPercent(0.51, decimals: 0), '51 %');
    });

    test('parses both decimal separators', () {
      expect(MoneyFormatter.tryParse('2.345,00'), 2345);
      expect(MoneyFormatter.tryParse('813,50'), 813.5);
      expect(MoneyFormatter.tryParse('813.50'), 813.5);
      expect(MoneyFormatter.tryParse('120'), 120);
      expect(MoneyFormatter.tryParse('Bs 65,00'), 65);
    });

    test('returns null for input that is not a number', () {
      expect(MoneyFormatter.tryParse(''), isNull);
      expect(MoneyFormatter.tryParse('abc'), isNull);
    });
  });
}

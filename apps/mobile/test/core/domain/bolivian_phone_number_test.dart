import 'package:cumavi_pos_mobile/core/domain/bolivian_phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BolivianPhoneNumber', () {
    test('keeps only the digits and drops the country code', () {
      expect(BolivianPhoneNumber.normalize('765 432 10'), '76543210');
      expect(BolivianPhoneNumber.normalize('+591 76543210'), '76543210');
    });

    test('accepts 8-digit mobiles starting with 6 or 7', () {
      expect(BolivianPhoneNumber.isValidMobile('76543210'), isTrue);
      expect(BolivianPhoneNumber.isValidMobile('6123-4567'), isTrue);
      expect(BolivianPhoneNumber.isValidMobile('+591 71234567'), isTrue);
    });

    test('rejects landlines and incomplete numbers', () {
      expect(BolivianPhoneNumber.isValidMobile('33456789'), isFalse);
      expect(BolivianPhoneNumber.isValidMobile('7654321'), isFalse);
      expect(BolivianPhoneNumber.isValidMobile(''), isFalse);
    });

    test('formats numbers the way WhatsApp links expect', () {
      expect(BolivianPhoneNumber.toInternational('765 43210'), '59176543210');
    });
  });
}

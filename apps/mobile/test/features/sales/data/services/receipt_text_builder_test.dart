import 'dart:convert';

import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/features/sales/data/services/escpos_receipt_encoder.dart';
import 'package:cumavi_pos_mobile/features/sales/data/services/receipt_text_builder.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt_options.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_line.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final AppLocalizations l10n = lookupAppLocalizations(const Locale('es'));

  // Two sizes of the same sneakers and a product without variants.
  final Receipt receipt = Receipt(
    sale: Sale(
      id: 'sale-20',
      number: 20,
      createdAt: DateTime(2026, 9, 18, 16, 5),
      lines: const <SaleLine>[
        SaleLine(
          productId: 'p-001',
          productName: 'Zapatillas urbanas',
          unitPrice: 450,
          quantity: 2,
          variantId: 'azul/40',
          variantLabel: 'Azul · 40',
        ),
        SaleLine(
          productId: 'p-001',
          productName: 'Zapatillas urbanas',
          unitPrice: 450,
          quantity: 1,
          variantId: 'rojo/38',
          variantLabel: 'Rojo · 38',
        ),
        SaleLine(
          productId: 'p-006',
          productName: 'Lentes de sol clásicos',
          unitPrice: 120,
          quantity: 1,
        ),
      ],
      discount: 0,
      paymentMethod: PaymentMethod.cash,
      amountReceived: 1500,
      cashierName: 'Carla Mamani',
    ),
  );

  setUpAll(() => initializeDateFormatting('es'));

  group('ReceiptTextBuilder', () {
    final ReceiptTextBuilder builder = ReceiptTextBuilder(l10n);

    test('names each line with its variant', () {
      final String text = builder.build(receipt);

      expect(text, contains('2 x Zapatillas urbanas (Azul · 40) — Bs 900,00'));
      expect(text, contains('1 x Zapatillas urbanas (Rojo · 38) — Bs 450,00'));
      expect(text, contains('1 x Lentes de sol clásicos — Bs 120,00'));
      expect(text, contains('*TOTAL: Bs 1.470,00*'));
    });

    test('keeps the plain name of a product without variants', () {
      expect(
        builder.itemName(receipt.sale.lines.last),
        'Lentes de sol clásicos',
      );
    });
  });

  test('the thermal receipt prints the variant in Latin-1', () async {
    final List<int> bytes = await EscPosReceiptEncoder(l10n)
        .encode(receipt, ReceiptPaperWidth.mm58);

    bool containsText(String text) {
      final List<int> encoded = latin1.encode(text);
      for (int start = 0; start <= bytes.length - encoded.length; start++) {
        int matched = 0;
        while (matched < encoded.length &&
            bytes[start + matched] == encoded[matched]) {
          matched++;
        }
        if (matched == encoded.length) return true;
      }
      return false;
    }

    expect(containsText('Zapatillas urbanas'), isTrue);
    expect(containsText('  Azul · 40'), isTrue);
    expect(containsText('  Rojo · 38'), isTrue);
  });
}

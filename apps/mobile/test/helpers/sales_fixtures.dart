import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt_options.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_line.dart';

/// Sale #19: two lines, cash payment with change.
final Sale sampleSale = Sale(
  id: 'sale-19',
  number: 19,
  createdAt: DateTime(2026, 9, 17, 11, 24),
  lines: const <SaleLine>[
    SaleLine(
      productId: 'p-1',
      productName: 'Zapatillas urbanas rojas',
      unitPrice: 450,
      quantity: 1,
    ),
    SaleLine(
      productId: 'p-2',
      productName: 'Medias deportivas',
      unitPrice: 25,
      quantity: 2,
    ),
  ],
  discount: 0,
  paymentMethod: PaymentMethod.cash,
  amountReceived: 600,
  cashierName: 'Carla Mamani',
);

final Receipt sampleReceipt = Receipt(sale: sampleSale);

const PrinterDevice counterPrinter = PrinterDevice(
  address: '66:22:11:AA:BB:01',
  name: 'Impresora mostrador',
);

const PrinterDevice backupPrinter = PrinterDevice(
  address: '66:22:11:AA:BB:02',
  name: 'Impresora depósito',
);

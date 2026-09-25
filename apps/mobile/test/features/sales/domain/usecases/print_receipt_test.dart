import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/services/receipt_printer.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/print_receipt.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_receipt_services.dart';
import '../../../../helpers/sales_fixtures.dart';

void main() {
  late FakeReceiptPrinter printer;
  late PrintReceipt printReceipt;

  setUp(() {
    printer = FakeReceiptPrinter();
    printReceipt = PrintReceipt(printer);
  });

  PrintJob jobWith(int copies) =>
      PrintJob(receipt: sampleReceipt, printer: counterPrinter, copies: copies);

  test('sends a valid job to the printer', () async {
    final Result<void> result = await printReceipt(jobWith(2));

    expect(result, isA<Success<void>>());
    expect(printer.jobs, <PrintJob>[jobWith(2)]);
  });

  test('rejects copies outside the allowed range', () async {
    for (final int copies in <int>[0, PrintReceipt.maxCopies + 1]) {
      final Result<void> result = await printReceipt(jobWith(copies));

      expect(
        result,
        isA<Failed<void>>().having(
          (Failed<void> failed) => failed.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      );
    }
    expect(printer.jobs, isEmpty);
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt_options.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/services/receipt_printer.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/get_paired_printers.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/print_receipt.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/print_receipt_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/print_receipt_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_receipt_services.dart';
import '../../../../helpers/sales_fixtures.dart';

void main() {
  late FakeReceiptPrinter printer;

  setUp(() {
    printer = FakeReceiptPrinter(
      printers: <PrinterDevice>[counterPrinter, backupPrinter],
    );
  });

  PrintReceiptCubit buildCubit() => PrintReceiptCubit(
    getPairedPrinters: GetPairedPrinters(printer),
    printReceipt: PrintReceipt(printer),
  );

  blocTest<PrintReceiptCubit, PrintReceiptState>(
    'selects the first paired printer',
    build: buildCubit,
    act: (PrintReceiptCubit cubit) => cubit.loadPrinters(),
    verify: (PrintReceiptCubit cubit) {
      expect(cubit.state.status, PrintReceiptStatus.ready);
      expect(cubit.state.selectedPrinter, counterPrinter);
    },
  );

  blocTest<PrintReceiptCubit, PrintReceiptState>(
    'keeps the chosen printer after searching again',
    build: buildCubit,
    act: (PrintReceiptCubit cubit) async {
      await cubit.loadPrinters();
      cubit.printerSelected(backupPrinter.address);
      await cubit.loadPrinters();
    },
    verify: (PrintReceiptCubit cubit) {
      expect(cubit.state.selectedPrinter, backupPrinter);
    },
  );

  blocTest<PrintReceiptCubit, PrintReceiptState>(
    'never goes beyond the allowed copies',
    build: buildCubit,
    act: (PrintReceiptCubit cubit) {
      for (int tap = 0; tap < PrintReceipt.maxCopies + 3; tap++) {
        cubit.incrementCopies();
      }
    },
    verify: (PrintReceiptCubit cubit) {
      expect(cubit.state.copies, PrintReceipt.maxCopies);
    },
  );

  blocTest<PrintReceiptCubit, PrintReceiptState>(
    'prints with the selected options',
    build: buildCubit,
    act: (PrintReceiptCubit cubit) async {
      await cubit.loadPrinters();
      cubit
        ..paperWidthSelected(ReceiptPaperWidth.mm80)
        ..incrementCopies();
      await cubit.print(sampleReceipt);
    },
    verify: (PrintReceiptCubit cubit) {
      expect(cubit.state.status, PrintReceiptStatus.printed);
      expect(
        printer.jobs.single,
        PrintJob(
          receipt: sampleReceipt,
          printer: counterPrinter,
          paperWidth: ReceiptPaperWidth.mm80,
          copies: 2,
        ),
      );
    },
  );

  blocTest<PrintReceiptCubit, PrintReceiptState>(
    'exposes the printer error',
    build: () {
      printer.printFailure = const ConflictFailure(
        FailureCode.printerNotResponding,
      );
      return buildCubit();
    },
    act: (PrintReceiptCubit cubit) async {
      await cubit.loadPrinters();
      await cubit.print(sampleReceipt);
    },
    verify: (PrintReceiptCubit cubit) {
      expect(cubit.state.status, PrintReceiptStatus.failure);
      expect(
        cubit.state.failure,
        const ConflictFailure(FailureCode.printerNotResponding),
      );
    },
  );
}

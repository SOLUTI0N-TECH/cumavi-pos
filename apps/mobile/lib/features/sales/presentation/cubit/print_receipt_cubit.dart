import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/services/receipt_printer.dart';
import '../../domain/usecases/get_paired_printers.dart';
import '../../domain/usecases/print_receipt.dart';
import 'print_receipt_state.dart';

/// Print sheet: paired printers, paper width, copies and the print action.
class PrintReceiptCubit extends Cubit<PrintReceiptState> {
  PrintReceiptCubit({
    required GetPairedPrinters getPairedPrinters,
    required PrintReceipt printReceipt,
  }) : _getPairedPrinters = getPairedPrinters,
       _printReceipt = printReceipt,
       super(const PrintReceiptState());

  final GetPairedPrinters _getPairedPrinters;
  final PrintReceipt _printReceipt;

  Future<void> loadPrinters() async {
    emit(state.copyWith(status: PrintReceiptStatus.loading));

    switch (await _getPairedPrinters(const NoParams())) {
      case Success<List<PrinterDevice>>(:final List<PrinterDevice> value):
        emit(
          state.copyWith(
            status: PrintReceiptStatus.ready,
            printers: value,
            // Keep the previous choice when it is still paired.
            selectedAddress:
                value.any(
                  (PrinterDevice printer) =>
                      printer.address == state.selectedAddress,
                )
                ? state.selectedAddress
                : value.firstOrNull?.address,
          ),
        );
      case Failed<List<PrinterDevice>>(:final failure):
        emit(
          state.copyWith(status: PrintReceiptStatus.failure, failure: failure),
        );
    }
  }

  void printerSelected(String address) => emit(
    state.copyWith(status: PrintReceiptStatus.ready, selectedAddress: address),
  );

  void paperWidthSelected(ReceiptPaperWidth width) =>
      emit(state.copyWith(paperWidth: width));

  void incrementCopies() {
    if (state.copies >= PrintReceipt.maxCopies) return;
    emit(state.copyWith(copies: state.copies + 1));
  }

  void decrementCopies() {
    if (state.copies <= 1) return;
    emit(state.copyWith(copies: state.copies - 1));
  }

  Future<void> print(Receipt receipt) async {
    final PrinterDevice? printer = state.selectedPrinter;
    if (printer == null) return;
    emit(state.copyWith(status: PrintReceiptStatus.printing));

    final Result<void> result = await _printReceipt(
      PrintJob(
        receipt: receipt,
        printer: printer,
        paperWidth: state.paperWidth,
        copies: state.copies,
      ),
    );

    switch (result) {
      case Success<void>():
        emit(state.copyWith(status: PrintReceiptStatus.printed));
      case Failed<void>(:final failure):
        emit(
          state.copyWith(status: PrintReceiptStatus.failure, failure: failure),
        );
    }
  }
}

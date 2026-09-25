import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';
import '../entities/receipt.dart';
import '../entities/receipt_options.dart';

/// Everything needed to print a receipt.
final class PrintJob extends Equatable {
  const PrintJob({
    required this.receipt,
    required this.printer,
    this.paperWidth = ReceiptPaperWidth.mm58,
    this.copies = 1,
  });

  final Receipt receipt;
  final PrinterDevice printer;
  final ReceiptPaperWidth paperWidth;
  final int copies;

  @override
  List<Object?> get props => <Object?>[receipt, printer, paperWidth, copies];
}

/// Prints receipts on thermal printers.
abstract interface class ReceiptPrinter {
  /// Printers already paired with the device.
  Future<Result<List<PrinterDevice>>> getPairedPrinters();

  Future<Result<void>> print(PrintJob job);
}

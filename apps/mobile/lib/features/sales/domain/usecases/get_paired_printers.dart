import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/receipt_options.dart';
import '../services/receipt_printer.dart';

/// Printers paired with the device, to choose where to print.
final class GetPairedPrinters
    implements UseCase<List<PrinterDevice>, NoParams> {
  const GetPairedPrinters(this._printer);

  final ReceiptPrinter _printer;

  @override
  Future<Result<List<PrinterDevice>>> call(NoParams input) =>
      _printer.getPairedPrinters();
}

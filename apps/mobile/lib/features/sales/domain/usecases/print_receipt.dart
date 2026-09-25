import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../services/receipt_printer.dart';

/// Prints a receipt on a thermal printer.
final class PrintReceipt implements UseCase<void, PrintJob> {
  const PrintReceipt(this._printer);

  /// Beyond this a roll runs out quickly; more copies are a mistake.
  static const int maxCopies = 5;

  final ReceiptPrinter _printer;

  @override
  Future<Result<void>> call(PrintJob input) async {
    if (input.copies < 1 || input.copies > maxCopies) {
      return const Failed<void>(
        ValidationFailure(FailureCode.invalidCopies, detail: '$maxCopies'),
      );
    }
    return _printer.print(input);
  }
}

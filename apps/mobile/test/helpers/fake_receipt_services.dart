import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt_options.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/services/receipt_printer.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/services/receipt_sharer.dart';

/// Records print jobs and answers with the configured printers.
class FakeReceiptPrinter implements ReceiptPrinter {
  FakeReceiptPrinter({
    this.printers = const <PrinterDevice>[],
    this.printFailure,
  });

  List<PrinterDevice> printers;
  Failure? printFailure;
  final List<PrintJob> jobs = <PrintJob>[];

  @override
  Future<Result<List<PrinterDevice>>> getPairedPrinters() async =>
      Success<List<PrinterDevice>>(printers);

  @override
  Future<Result<void>> print(PrintJob job) async {
    jobs.add(job);
    final Failure? failure = printFailure;
    return failure == null ? const Success<void>(null) : Failed<void>(failure);
  }
}

/// Records share requests and always succeeds.
class FakeReceiptSharer implements ReceiptSharer {
  final List<ReceiptShareRequest> requests = <ReceiptShareRequest>[];

  @override
  Future<Result<void>> share(ReceiptShareRequest request) async {
    requests.add(request);
    return const Success<void>(null);
  }
}

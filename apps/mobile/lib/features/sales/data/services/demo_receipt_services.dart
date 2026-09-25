import '../../../../core/utils/result.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/services/receipt_printer.dart';
import '../../domain/services/receipt_sharer.dart';

/// Printer stand-in for tests and platforms without Bluetooth (web,
/// desktop): lists two printers and "prints" after a short wait.
final class DemoReceiptPrinter implements ReceiptPrinter {
  const DemoReceiptPrinter({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  @override
  Future<Result<List<PrinterDevice>>> getPairedPrinters() async {
    await Future<void>.delayed(latency);
    return const Success<List<PrinterDevice>>(<PrinterDevice>[
      PrinterDevice(address: 'demo-58', name: 'Térmica 58 mm'),
      PrinterDevice(address: 'demo-80', name: 'Térmica 80 mm'),
    ]);
  }

  @override
  Future<Result<void>> print(PrintJob job) async {
    await Future<void>.delayed(latency);
    return const Success<void>(null);
  }
}

/// Sharing stand-in: accepts every request without leaving the app.
final class DemoReceiptSharer implements ReceiptSharer {
  const DemoReceiptSharer();

  @override
  Future<Result<void>> share(ReceiptShareRequest request) async {
    return const Success<void>(null);
  }
}

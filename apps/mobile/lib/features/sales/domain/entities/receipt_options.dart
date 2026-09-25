import 'package:equatable/equatable.dart';

/// Thermal paper widths used by the printers sold in Bolivia.
enum ReceiptPaperWidth { mm58, mm80 }

/// File the receipt is exported as.
enum ReceiptFileFormat { image, pdf }

/// A printer the device can talk to.
final class PrinterDevice extends Equatable {
  const PrinterDevice({required this.address, required this.name});

  /// Bluetooth MAC address (or the platform identifier on iOS).
  final String address;

  /// Name the printer announces; some cheap models announce none.
  final String name;

  @override
  List<Object?> get props => <Object?>[address, name];
}

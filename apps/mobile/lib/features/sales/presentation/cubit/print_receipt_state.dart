import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/receipt_options.dart';

enum PrintReceiptStatus { loading, ready, printing, printed, failure }

final class PrintReceiptState extends Equatable {
  const PrintReceiptState({
    this.status = PrintReceiptStatus.loading,
    this.printers = const <PrinterDevice>[],
    this.selectedAddress,
    this.paperWidth = ReceiptPaperWidth.mm58,
    this.copies = 1,
    this.failure,
  });

  final PrintReceiptStatus status;
  final List<PrinterDevice> printers;
  final String? selectedAddress;
  final ReceiptPaperWidth paperWidth;
  final int copies;
  final Failure? failure;

  PrinterDevice? get selectedPrinter => printers
      .where((PrinterDevice printer) => printer.address == selectedAddress)
      .firstOrNull;

  bool get isBusy =>
      status == PrintReceiptStatus.loading ||
      status == PrintReceiptStatus.printing;

  bool get canPrint => selectedPrinter != null && !isBusy;

  PrintReceiptState copyWith({
    PrintReceiptStatus? status,
    List<PrinterDevice>? printers,
    String? selectedAddress,
    ReceiptPaperWidth? paperWidth,
    int? copies,
    Failure? failure,
  }) {
    return PrintReceiptState(
      status: status ?? this.status,
      printers: printers ?? this.printers,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paperWidth: paperWidth ?? this.paperWidth,
      copies: copies ?? this.copies,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    printers,
    selectedAddress,
    paperWidth,
    copies,
    failure,
  ];
}

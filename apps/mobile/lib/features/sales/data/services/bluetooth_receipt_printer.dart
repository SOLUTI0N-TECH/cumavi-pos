import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/services/receipt_printer.dart';
import 'escpos_receipt_encoder.dart';

/// Prints on Bluetooth thermal printers already paired with the phone.
///
/// Keeps the connection open between receipts: reconnecting for every sale is
/// slow and is what made the La Case POS print only once.
final class BluetoothReceiptPrinter implements ReceiptPrinter {
  BluetoothReceiptPrinter({required EscPosReceiptEncoder encoder})
    : _encoder = encoder;

  /// A printer that does not answer by then is off or out of range.
  static const Duration _connectTimeout = Duration(seconds: 15);

  final EscPosReceiptEncoder _encoder;
  String? _connectedAddress;

  @override
  Future<Result<List<PrinterDevice>>> getPairedPrinters() async {
    final Failure? readiness = await _checkBluetoothReady();
    if (readiness != null) return Failed<List<PrinterDevice>>(readiness);

    try {
      final List<BluetoothInfo> paired =
          await PrintBluetoothThermal.pairedBluetooths;
      return Success<List<PrinterDevice>>(
        paired
            .where((BluetoothInfo device) => device.macAdress.isNotEmpty)
            .map(
              (BluetoothInfo device) =>
                  PrinterDevice(address: device.macAdress, name: device.name),
            )
            .toList(),
      );
    } on Object catch (error) {
      debugPrint('Listing printers failed: $error');
      return const Failed<List<PrinterDevice>>(
        UnexpectedFailure(FailureCode.printersUnavailable),
      );
    }
  }

  @override
  Future<Result<void>> print(PrintJob job) async {
    final Failure? readiness = await _checkBluetoothReady();
    if (readiness != null) return Failed<void>(readiness);

    try {
      if (!await _ensureConnected(job.printer.address)) {
        return Failed<void>(
          ConflictFailure(
            FailureCode.printerUnreachable,
            detail: job.printer.name,
          ),
        );
      }

      final List<int> bytes = await _encoder.encode(
        job.receipt,
        job.paperWidth,
      );
      for (int copy = 0; copy < job.copies; copy++) {
        if (!await PrintBluetoothThermal.writeBytes(bytes)) {
          // A dead socket reports false; forget it so the next try reconnects.
          _connectedAddress = null;
          return const Failed<void>(
            ConflictFailure(FailureCode.printerNotResponding),
          );
        }
      }
      return const Success<void>(null);
    } on TimeoutException {
      _connectedAddress = null;
      return const Failed<void>(ConflictFailure(FailureCode.printerTimeout));
    } on Object catch (error) {
      debugPrint('Printing failed: $error');
      _connectedAddress = null;
      return const Failed<void>(UnexpectedFailure(FailureCode.printFailed));
    }
  }

  Future<bool> _ensureConnected(String address) async {
    final bool isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected && _connectedAddress == address) return true;

    if (isConnected) await PrintBluetoothThermal.disconnect;
    final bool connected = await PrintBluetoothThermal.connect(
      macPrinterAddress: address,
    ).timeout(_connectTimeout);
    _connectedAddress = connected ? address : null;
    return connected;
  }

  /// Permissions (Android 12+ asks for nearby devices) and Bluetooth on.
  Future<Failure?> _checkBluetoothReady() async {
    final List<Permission> permissions = Platform.isAndroid
        ? <Permission>[Permission.bluetoothConnect, Permission.bluetoothScan]
        : <Permission>[Permission.bluetooth];
    final Map<Permission, PermissionStatus> statuses = await permissions
        .request();
    final bool granted = statuses.values.every(
      (PermissionStatus status) => status.isGranted || status.isLimited,
    );
    if (!granted) {
      return const ConflictFailure(FailureCode.bluetoothPermissionDenied);
    }
    if (!await PrintBluetoothThermal.bluetoothEnabled) {
      return const ConflictFailure(FailureCode.bluetoothDisabled);
    }
    return null;
  }
}

import 'package:flutter/widgets.dart';

/// Why the scanner is open; it words the screen accordingly.
enum ScanPurpose {
  /// Adds the scanned product to the sale.
  sell,

  /// Opens the scanned product in the inventory.
  find,

  /// Fills a barcode field of the product form.
  assign,
}

/// Opens the scanner and resolves with the code read or typed, or `null`
/// when the seller closes it.
typedef ScanCode = Future<String?> Function();

/// Live camera preview that reads barcodes. The real one uses the device
/// camera; the demo one (tests, desktop) shows a placeholder, and the
/// scanner screen still offers typing a code and the demo codes.
abstract interface class BarcodeCamera {
  /// Whether this camera really reads codes.
  bool get isLive;

  /// Preview that calls [onDetected] with each code it reads.
  Widget preview({required ValueChanged<String> onDetected});
}

import 'package:equatable/equatable.dart';

/// Where a receipt is sent.
sealed class ReceiptShareTarget extends Equatable {
  const ReceiptShareTarget();

  @override
  List<Object?> get props => <Object?>[];
}

/// Opens WhatsApp on the customer's chat with the receipt ready to send.
final class WhatsAppShareTarget extends ReceiptShareTarget {
  const WhatsAppShareTarget(this.phoneNumber);

  /// Bolivian mobile number, with or without the country code.
  final String phoneNumber;

  @override
  List<Object?> get props => <Object?>[phoneNumber];
}

/// Opens the mail app with the receipt in the body.
final class EmailShareTarget extends ReceiptShareTarget {
  const EmailShareTarget();
}

/// Saves the file on the device (gallery for images).
final class DeviceStorageShareTarget extends ReceiptShareTarget {
  const DeviceStorageShareTarget();
}

/// Opens the system share sheet with the file attached.
final class SystemShareTarget extends ReceiptShareTarget {
  const SystemShareTarget();
}

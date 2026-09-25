import 'package:equatable/equatable.dart';

import '../../../../core/utils/result.dart';
import '../entities/receipt.dart';
import '../entities/receipt_options.dart';
import '../entities/receipt_share_target.dart';

/// A receipt to send, in which format and to where.
final class ReceiptShareRequest extends Equatable {
  const ReceiptShareRequest({
    required this.receipt,
    required this.target,
    this.format = ReceiptFileFormat.image,
  });

  final Receipt receipt;
  final ReceiptShareTarget target;
  final ReceiptFileFormat format;

  @override
  List<Object?> get props => <Object?>[receipt, target, format];
}

/// Sends receipts outside the app: WhatsApp, email, files, share sheet.
abstract interface class ReceiptSharer {
  Future<Result<void>> share(ReceiptShareRequest request);
}

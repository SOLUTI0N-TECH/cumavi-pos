import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/entities/receipt_share_target.dart';

enum ShareReceiptStatus { idle, sharing, shared, failure }

final class ShareReceiptState extends Equatable {
  const ShareReceiptState({
    this.status = ShareReceiptStatus.idle,
    this.format = ReceiptFileFormat.image,
    this.phoneNumber = '',
    this.lastTarget,
    this.failure,
  });

  final ShareReceiptStatus status;
  final ReceiptFileFormat format;

  /// Customer's WhatsApp number as typed.
  final String phoneNumber;

  /// Destination of the last attempt, to word the confirmation.
  final ReceiptShareTarget? lastTarget;
  final Failure? failure;

  bool get isSharing => status == ShareReceiptStatus.sharing;

  ShareReceiptState copyWith({
    ShareReceiptStatus? status,
    ReceiptFileFormat? format,
    String? phoneNumber,
    ReceiptShareTarget? lastTarget,
    Failure? failure,
  }) {
    return ShareReceiptState(
      status: status ?? this.status,
      format: format ?? this.format,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastTarget: lastTarget ?? this.lastTarget,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    format,
    phoneNumber,
    lastTarget,
    failure,
  ];
}

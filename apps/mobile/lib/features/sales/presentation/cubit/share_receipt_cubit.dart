import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/entities/receipt_share_target.dart';
import '../../domain/services/receipt_sharer.dart';
import '../../domain/usecases/share_receipt.dart';
import 'share_receipt_state.dart';

/// Share sheet: file format, customer's WhatsApp and destinations.
class ShareReceiptCubit extends Cubit<ShareReceiptState> {
  ShareReceiptCubit({required ShareReceipt shareReceipt})
    : _shareReceipt = shareReceipt,
      super(const ShareReceiptState());

  final ShareReceipt _shareReceipt;

  void formatSelected(ReceiptFileFormat format) =>
      emit(state.copyWith(format: format, status: ShareReceiptStatus.idle));

  void phoneNumberChanged(String value) =>
      emit(state.copyWith(phoneNumber: value, status: ShareReceiptStatus.idle));

  Future<void> sendToWhatsApp(Receipt receipt) =>
      share(receipt, WhatsAppShareTarget(state.phoneNumber));

  Future<void> share(Receipt receipt, ReceiptShareTarget target) async {
    emit(
      state.copyWith(status: ShareReceiptStatus.sharing, lastTarget: target),
    );

    final Result<void> result = await _shareReceipt(
      ReceiptShareRequest(
        receipt: receipt,
        target: target,
        format: state.format,
      ),
    );

    switch (result) {
      case Success<void>():
        emit(state.copyWith(status: ShareReceiptStatus.shared));
      case Failed<void>(:final failure):
        emit(
          state.copyWith(status: ShareReceiptStatus.failure, failure: failure),
        );
    }
  }
}

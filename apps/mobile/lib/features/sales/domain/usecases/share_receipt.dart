import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/receipt_share_target.dart';
import '../services/receipt_sharer.dart';

/// Sends a receipt to WhatsApp, email, the device storage or another app.
final class ShareReceipt implements UseCase<void, ReceiptShareRequest> {
  const ShareReceipt(this._sharer);

  final ReceiptSharer _sharer;

  @override
  Future<Result<void>> call(ReceiptShareRequest input) async {
    if (input.target case WhatsAppShareTarget(:final String phoneNumber)
        when !BolivianPhoneNumber.isValidMobile(phoneNumber)) {
      return const Failed<void>(
        ValidationFailure(FailureCode.invalidMobileNumber),
      );
    }
    return _sharer.share(input);
  }
}

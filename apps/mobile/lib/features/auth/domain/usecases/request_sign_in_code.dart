import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/sent_verification_code.dart';
import '../repositories/auth_repository.dart';

/// Sends the SMS code to sign in with the phone of an existing account.
final class RequestSignInCode implements UseCase<SentVerificationCode, String> {
  const RequestSignInCode(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<SentVerificationCode>> call(String phoneNumber) async {
    if (!BolivianPhoneNumber.isValidMobile(phoneNumber)) {
      return const Failed<SentVerificationCode>(
        ValidationFailure(FailureCode.invalidMobileNumber),
      );
    }
    return _repository.requestSignInCode(
      BolivianPhoneNumber.normalize(phoneNumber),
    );
  }
}

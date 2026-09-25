import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/sent_verification_code.dart';
import '../repositories/auth_repository.dart';

/// Starts the phone registration by sending the verification code.
final class RequestPhoneCode
    implements UseCase<SentVerificationCode, PhoneRegistrationDraft> {
  const RequestPhoneCode(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<SentVerificationCode>> call(
    PhoneRegistrationDraft input,
  ) async {
    if (input.fullName.trim().split(RegExp(r'\s+')).length < 2) {
      return const Failed<SentVerificationCode>(
        ValidationFailure(FailureCode.fullNameRequired),
      );
    }
    if (!BolivianPhoneNumber.isValidMobile(input.phoneNumber)) {
      return const Failed<SentVerificationCode>(
        ValidationFailure(FailureCode.invalidMobileNumber),
      );
    }
    return _repository.requestPhoneCode(
      PhoneRegistrationDraft(
        fullName: input.fullName.trim(),
        phoneNumber: BolivianPhoneNumber.normalize(input.phoneNumber),
      ),
    );
  }
}

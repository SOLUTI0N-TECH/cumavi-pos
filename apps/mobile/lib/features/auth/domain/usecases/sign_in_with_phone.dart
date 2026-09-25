import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_account.dart';
import '../repositories/auth_repository.dart';
import 'verify_phone_code.dart';

/// Phone + SMS code sign-in.
final class SignInWithPhone implements UseCase<UserAccount, PhoneCredentials> {
  const SignInWithPhone(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserAccount>> call(PhoneCredentials input) async {
    if (!BolivianPhoneNumber.isValidMobile(input.phoneNumber)) {
      return const Failed<UserAccount>(
        ValidationFailure(FailureCode.invalidMobileNumber),
      );
    }
    final String code = input.code.replaceAll(RegExp(r'\D'), '');
    if (code.length != VerifyPhoneCode.codeLength) {
      return const Failed<UserAccount>(
        ValidationFailure(FailureCode.verificationCodeIncomplete),
      );
    }
    return _repository.signInWithPhone(
      PhoneCredentials(
        phoneNumber: BolivianPhoneNumber.normalize(input.phoneNumber),
        code: code,
      ),
    );
  }
}

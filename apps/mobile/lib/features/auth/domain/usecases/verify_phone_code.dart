import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_account.dart';
import '../repositories/auth_repository.dart';

/// Input of [VerifyPhoneCode].
final class PhoneVerification {
  const PhoneVerification({required this.draft, required this.code});

  final PhoneRegistrationDraft draft;
  final String code;
}

/// Confirms the SMS code and creates the account.
final class VerifyPhoneCode implements UseCase<UserAccount, PhoneVerification> {
  const VerifyPhoneCode(this._repository);

  static const int codeLength = 6;

  final AuthRepository _repository;

  @override
  Future<Result<UserAccount>> call(PhoneVerification input) async {
    final String digits = input.code.replaceAll(RegExp(r'\D'), '');
    if (digits.length != codeLength) {
      return const Failed<UserAccount>(
        ValidationFailure(FailureCode.verificationCodeIncomplete),
      );
    }
    return _repository.verifyPhoneCode(draft: input.draft, code: digits);
  }
}

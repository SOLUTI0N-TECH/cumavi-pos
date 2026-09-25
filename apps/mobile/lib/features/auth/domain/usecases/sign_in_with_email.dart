import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_account.dart';
import '../repositories/auth_repository.dart';

/// Email + password sign-in.
final class SignInWithEmail implements UseCase<UserAccount, EmailCredentials> {
  const SignInWithEmail(this._repository);

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final AuthRepository _repository;

  @override
  Future<Result<UserAccount>> call(EmailCredentials input) async {
    if (!_emailPattern.hasMatch(input.email.trim())) {
      return const Failed<UserAccount>(
        ValidationFailure(FailureCode.invalidEmail),
      );
    }
    if (input.password.length < 8) {
      return const Failed<UserAccount>(
        ValidationFailure(FailureCode.passwordTooShort),
      );
    }
    return _repository.signInWithEmail(input);
  }
}

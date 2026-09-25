import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_account.dart';
import '../repositories/auth_repository.dart';

/// Google sign-in, shared by the sign-in and the register screens.
final class SignInWithGoogle implements UseCase<UserAccount, NoParams> {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<UserAccount>> call(NoParams input) =>
      _repository.signInWithGoogle();
}

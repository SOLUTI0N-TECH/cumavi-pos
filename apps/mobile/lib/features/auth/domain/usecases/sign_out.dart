import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Signs the current user out. The business and the cash drawer stay as they
/// are: the next person to sign in finds the store ready.
final class SignOut implements UseCase<void, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(NoParams input) => _repository.signOut();
}

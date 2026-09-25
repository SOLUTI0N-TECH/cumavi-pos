import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/session_info.dart';
import '../repositories/session_repository.dart';

/// Reads the current session. Async to keep the [UseCase] contract, which
/// also makes it a drop-in when the data starts coming from storage.
final class GetSessionInfo implements UseCase<SessionInfo, NoParams> {
  const GetSessionInfo(this._repository);

  final SessionRepository _repository;

  @override
  Future<Result<SessionInfo>> call(NoParams input) async {
    return Success<SessionInfo>(
      SessionInfo(
        user: _repository.currentUser,
        business: _repository.currentBusiness,
      ),
    );
  }
}

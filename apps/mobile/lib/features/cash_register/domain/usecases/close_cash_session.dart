import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/cash_session.dart';
import '../repositories/cash_register_repository.dart';

/// Closes the drawer after the cashier counts the money.
final class CloseCashSession
    implements UseCase<CashSession, CloseCashSessionInput> {
  const CloseCashSession(this._repository);

  final CashRegisterRepository _repository;

  @override
  Future<Result<CashSession>> call(CloseCashSessionInput input) async {
    if (input.countedAmount < 0) {
      return const Failed<CashSession>(
        ValidationFailure(FailureCode.negativeCountedCash),
      );
    }
    return _repository.closeSession(input);
  }
}

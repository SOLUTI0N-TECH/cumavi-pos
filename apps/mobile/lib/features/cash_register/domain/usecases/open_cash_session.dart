import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/cash_session.dart';
import '../repositories/cash_register_repository.dart';

/// Opens the drawer with the cash the store starts the day with.
final class OpenCashSession implements UseCase<CashSession, double> {
  const OpenCashSession(this._repository);

  final CashRegisterRepository _repository;

  @override
  Future<Result<CashSession>> call(double input) async {
    if (input < 0) {
      return const Failed<CashSession>(
        ValidationFailure(FailureCode.negativeOpeningAmount),
      );
    }
    return _repository.openSession(openingAmount: input);
  }
}

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/cash_session.dart';
import '../repositories/cash_register_repository.dart';

/// Current state of the cash drawer, which decides whether the Ventas tab
/// shows the opening form or the cart.
final class GetCurrentCashSession implements UseCase<CashSession?, NoParams> {
  const GetCurrentCashSession(this._repository);

  final CashRegisterRepository _repository;

  @override
  Future<Result<CashSession?>> call(NoParams input) =>
      _repository.getCurrentSession();
}

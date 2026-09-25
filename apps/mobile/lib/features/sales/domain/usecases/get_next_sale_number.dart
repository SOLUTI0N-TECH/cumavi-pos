import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../repositories/sales_repository.dart';

/// Number the sale in progress will get once it is charged.
final class GetNextSaleNumber implements UseCase<int, NoParams> {
  const GetNextSaleNumber(this._repository);

  final SalesRepository _repository;

  @override
  Future<Result<int>> call(NoParams input) => _repository.getNextSaleNumber();
}

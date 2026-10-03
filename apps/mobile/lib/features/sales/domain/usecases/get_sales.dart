import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/sale.dart';
import '../entities/sale_query.dart';
import '../repositories/sales_repository.dart';

/// Past sales matching a [SaleQuery], newest first.
final class GetSales implements UseCase<List<Sale>, SaleQuery> {
  const GetSales(this._repository);

  final SalesRepository _repository;

  @override
  Future<Result<List<Sale>>> call(SaleQuery input) =>
      _repository.getSales(input);
}

/// One sale, for its detail screen.
final class GetSale implements UseCase<Sale, String> {
  const GetSale(this._repository);

  final SalesRepository _repository;

  @override
  Future<Result<Sale>> call(String saleId) => _repository.getSaleById(saleId);
}

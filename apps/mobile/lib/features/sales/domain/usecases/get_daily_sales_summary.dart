import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/daily_sales_summary.dart';
import '../repositories/sales_repository.dart';

/// Totals of a given day (today by default).
final class GetDailySalesSummary
    implements UseCase<DailySalesSummary, DateTime?> {
  const GetDailySalesSummary(this._repository);

  final SalesRepository _repository;

  @override
  Future<Result<DailySalesSummary>> call(DateTime? input) =>
      _repository.getDailySummary(input ?? DateTime.now());
}

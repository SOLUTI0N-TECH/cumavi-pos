import '../../../../core/utils/result.dart';
import '../entities/daily_sales_summary.dart';
import '../entities/sale.dart';
import '../entities/sale_draft.dart';

/// Stores sales and answers the aggregations the app needs.
abstract interface class SalesRepository {
  Future<Result<Sale>> registerSale(SaleDraft draft);

  Future<Result<Sale>> getSaleById(String id);

  /// Number the next sale will get, used by the sale screen header.
  Future<Result<int>> getNextSaleNumber();

  Future<Result<DailySalesSummary>> getDailySummary(DateTime date);

  /// Sales registered after [moment], used when closing the cash drawer.
  Future<Result<DailySalesSummary>> getSummarySince(DateTime moment);
}

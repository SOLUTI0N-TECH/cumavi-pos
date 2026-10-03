import '../../../../core/utils/result.dart';
import '../entities/daily_sales_summary.dart';
import '../entities/sale.dart';
import '../entities/sale_draft.dart';
import '../entities/sale_query.dart';
import '../entities/sale_return.dart';

/// Stores sales and answers the aggregations the app needs.
abstract interface class SalesRepository {
  Future<Result<Sale>> registerSale(SaleDraft draft);

  Future<Result<Sale>> getSaleById(String id);

  /// Sales matching [query], newest first.
  Future<Result<List<Sale>>> getSales(SaleQuery query);

  /// Marks the whole sale as cancelled by the current cashier.
  Future<Result<Sale>> cancelSale(String saleId, {required String reason});

  /// Stores a return of some units; it gets the next return number.
  Future<Result<SaleReturn>> registerReturn(SaleReturnDraft draft);

  /// Number the next sale will get, used by the sale screen header.
  Future<Result<int>> getNextSaleNumber();

  Future<Result<DailySalesSummary>> getDailySummary(DateTime date);

  /// Sales registered after [moment], used when closing the cash drawer.
  /// Like [getDailySummary], cancelled sales are left out and refunds made
  /// in the period are subtracted by method.
  Future<Result<DailySalesSummary>> getSummarySince(DateTime moment);
}

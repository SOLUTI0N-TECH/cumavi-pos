import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../../domain/entities/daily_sales_summary.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_data_source.dart';

/// Aggregates the stored sales into the summaries the app displays.
final class SalesRepositoryImpl implements SalesRepository {
  const SalesRepositoryImpl({
    required SalesDataSource dataSource,
    required SessionRepository sessionRepository,
  }) : _dataSource = dataSource,
       _sessionRepository = sessionRepository;

  final SalesDataSource _dataSource;
  final SessionRepository _sessionRepository;

  @override
  Future<Result<Sale>> registerSale(SaleDraft draft) async {
    try {
      final Sale sale = await _dataSource.insertSale(
        draft,
        cashierName: _sessionRepository.currentCashierName,
      );
      return Success<Sale>(sale);
    } on DataSourceException catch (exception) {
      return Failed<Sale>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<Sale>> getSaleById(String id) async {
    try {
      final List<Sale> sales = await _dataSource.fetchSales();
      final Sale? sale = sales
          .where((Sale candidate) => candidate.id == id)
          .firstOrNull;
      if (sale == null) {
        return const Failed<Sale>(NotFoundFailure(FailureCode.saleNotFound));
      }
      return Success<Sale>(sale);
    } on DataSourceException catch (exception) {
      return Failed<Sale>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<int>> getNextSaleNumber() async {
    try {
      return Success<int>(await _dataSource.fetchNextSaleNumber());
    } on DataSourceException catch (exception) {
      return Failed<int>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<DailySalesSummary>> getDailySummary(DateTime date) async {
    return _summarize(
      date: date,
      filter: (Sale sale) => _isSameDay(sale.createdAt, date),
    );
  }

  @override
  Future<Result<DailySalesSummary>> getSummarySince(DateTime moment) async {
    return _summarize(
      date: moment,
      filter: (Sale sale) => !sale.createdAt.isBefore(moment),
    );
  }

  Future<Result<DailySalesSummary>> _summarize({
    required DateTime date,
    required bool Function(Sale sale) filter,
  }) async {
    try {
      final List<Sale> sales = (await _dataSource.fetchSales())
          .where(filter)
          .toList();

      final Map<PaymentMethod, double> totals = <PaymentMethod, double>{};
      int soldUnits = 0;
      for (final Sale sale in sales) {
        totals.update(
          sale.paymentMethod,
          (double current) => current + sale.total,
          ifAbsent: () => sale.total,
        );
        soldUnits += sale.itemCount;
      }

      return Success<DailySalesSummary>(
        DailySalesSummary(
          date: date,
          saleCount: sales.length,
          soldUnits: soldUnits,
          totalsByMethod: totals,
        ),
      );
    } on DataSourceException catch (exception) {
      return Failed<DailySalesSummary>(UnexpectedFailure(exception.code));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

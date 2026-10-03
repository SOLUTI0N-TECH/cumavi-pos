import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../../domain/entities/daily_sales_summary.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';
import '../../domain/entities/sale_query.dart';
import '../../domain/entities/sale_return.dart';
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
  Future<Result<List<Sale>>> getSales(SaleQuery query) async {
    try {
      final List<Sale> sales =
          (await _dataSource.fetchSales())
              .where(
                (Sale sale) => query.matches(
                  sale.createdAt,
                  sale.paymentMethod,
                  sale.number,
                ),
              )
              .toList()
            ..sort((Sale a, Sale b) => b.createdAt.compareTo(a.createdAt));
      return Success<List<Sale>>(sales);
    } on DataSourceException catch (exception) {
      return Failed<List<Sale>>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<Sale>> cancelSale(
    String saleId, {
    required String reason,
  }) async {
    try {
      return Success<Sale>(
        await _dataSource.cancelSale(
          saleId,
          reason: reason,
          cancelledBy: _sessionRepository.currentCashierName,
        ),
      );
    } on DataSourceException catch (exception) {
      return Failed<Sale>(NotFoundFailure(exception.code));
    }
  }

  @override
  Future<Result<SaleReturn>> registerReturn(SaleReturnDraft draft) async {
    try {
      return Success<SaleReturn>(
        await _dataSource.insertReturn(
          draft,
          cashierName: _sessionRepository.currentCashierName,
        ),
      );
    } on DataSourceException catch (exception) {
      return Failed<SaleReturn>(NotFoundFailure(exception.code));
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
      inPeriod: (DateTime moment) => _isSameDay(moment, date),
    );
  }

  @override
  Future<Result<DailySalesSummary>> getSummarySince(DateTime moment) async {
    return _summarize(
      date: moment,
      inPeriod: (DateTime at) => !at.isBefore(moment),
    );
  }

  Future<Result<DailySalesSummary>> _summarize({
    required DateTime date,
    required bool Function(DateTime moment) inPeriod,
  }) async {
    try {
      final List<Sale> all = await _dataSource.fetchSales();
      // A cancelled sale never happened for the totals.
      final List<Sale> sales = all
          .where((Sale sale) => !sale.isCancelled && inPeriod(sale.createdAt))
          .toList();
      // Refunds count when they are made, whatever day the sale was.
      final List<SaleReturn> refunds = all
          .expand((Sale sale) => sale.returns)
          .where((SaleReturn refund) => inPeriod(refund.createdAt))
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
      final Map<PaymentMethod, double> refunded = <PaymentMethod, double>{};
      for (final SaleReturn refund in refunds) {
        refunded.update(
          refund.refundMethod,
          (double current) => current + refund.amount,
          ifAbsent: () => refund.amount,
        );
        totals.update(
          refund.refundMethod,
          (double current) => current - refund.amount,
          ifAbsent: () => -refund.amount,
        );
      }

      return Success<DailySalesSummary>(
        DailySalesSummary(
          date: date,
          saleCount: sales.length,
          soldUnits: soldUnits,
          totalsByMethod: totals,
          refundCount: refunds.length,
          refundsByMethod: refunded,
        ),
      );
    } on DataSourceException catch (exception) {
      return Failed<DailySalesSummary>(UnexpectedFailure(exception.code));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

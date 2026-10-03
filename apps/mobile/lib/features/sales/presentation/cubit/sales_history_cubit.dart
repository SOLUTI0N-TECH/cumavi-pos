import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_query.dart';
import '../../domain/entities/sales_day.dart';
import '../../domain/usecases/get_sales.dart';

enum SalesPeriod { today, yesterday, last7Days, custom }

enum SalesHistoryStatus { loading, ready, failure }

final class SalesHistoryState extends Equatable {
  const SalesHistoryState({
    this.status = SalesHistoryStatus.loading,
    this.period = SalesPeriod.today,
    this.customFrom,
    this.customTo,
    this.paymentMethod,
    this.numberQuery = '',
    this.sales = const <Sale>[],
    this.failure,
  });

  final SalesHistoryStatus status;
  final SalesPeriod period;

  /// First and last day of [SalesPeriod.custom], both included.
  final DateTime? customFrom;
  final DateTime? customTo;

  /// `null` shows every method.
  final PaymentMethod? paymentMethod;

  /// Sale number typed in the search, as typed (`#141`, `0141`…).
  final String numberQuery;

  /// Newest first.
  final List<Sale> sales;
  final Failure? failure;

  /// The number to look for, or `null` when the search has no digits.
  int? get searchedNumber =>
      int.tryParse(numberQuery.replaceAll(RegExp(r'\D'), ''));

  /// Searching by number looks through every date.
  bool get isSearchingNumber => searchedNumber != null;

  List<SalesDay> get days => SalesDay.group(sales);

  /// Money of the listed sales; cancelled ones don't count.
  double get total => sales
      .where((Sale sale) => !sale.isCancelled)
      .fold(0, (double sum, Sale sale) => sum + sale.total);

  SalesHistoryState copyWith({
    SalesHistoryStatus? status,
    SalesPeriod? period,
    DateTime? customFrom,
    DateTime? customTo,
    String? numberQuery,
    List<Sale>? sales,
    Failure? failure,
  }) => SalesHistoryState(
    status: status ?? this.status,
    period: period ?? this.period,
    customFrom: customFrom ?? this.customFrom,
    customTo: customTo ?? this.customTo,
    paymentMethod: paymentMethod,
    numberQuery: numberQuery ?? this.numberQuery,
    sales: sales ?? this.sales,
    failure: failure,
  );

  /// Same state with another method filter; `null` clears it.
  SalesHistoryState withPaymentMethod(PaymentMethod? method) =>
      SalesHistoryState(
        status: status,
        period: period,
        customFrom: customFrom,
        customTo: customTo,
        paymentMethod: method,
        numberQuery: numberQuery,
        sales: sales,
        failure: failure,
      );

  @override
  List<Object?> get props => <Object?>[
    status,
    period,
    customFrom,
    customTo,
    paymentMethod,
    numberQuery,
    sales,
    failure,
  ];
}

/// "Historial de ventas": past sales by period, payment method or number.
class SalesHistoryCubit extends Cubit<SalesHistoryState> {
  SalesHistoryCubit({required GetSales getSales, DateTime Function()? clock})
    : _getSales = getSales,
      _clock = clock ?? DateTime.now,
      super(const SalesHistoryState());

  final GetSales _getSales;
  final DateTime Function() _clock;

  Future<void> load() => _search();

  Future<void> periodSelected(SalesPeriod period) {
    emit(state.copyWith(period: period));
    return _search();
  }

  /// A custom range, from its first to its last day.
  Future<void> rangeSelected(DateTime from, DateTime to) {
    emit(
      state.copyWith(
        period: SalesPeriod.custom,
        customFrom: _day(from),
        customTo: _day(to),
      ),
    );
    return _search();
  }

  Future<void> paymentMethodSelected(PaymentMethod? method) {
    emit(state.withPaymentMethod(method));
    return _search();
  }

  Future<void> numberChanged(String query) {
    emit(state.copyWith(numberQuery: query));
    return _search();
  }

  Future<void> _search() async {
    final SaleQuery query = _query();
    emit(state.copyWith(status: SalesHistoryStatus.loading));
    final Result<List<Sale>> result = await _getSales(query);
    // A newer filter may have been picked while this one was loading.
    if (query != _query()) return;
    switch (result) {
      case Success<List<Sale>>(:final List<Sale> value):
        emit(state.copyWith(status: SalesHistoryStatus.ready, sales: value));
      case Failed<List<Sale>>(:final failure):
        emit(
          state.copyWith(status: SalesHistoryStatus.failure, failure: failure),
        );
    }
  }

  SaleQuery _query() {
    final int? number = state.searchedNumber;
    if (number != null) return SaleQuery(number: number);

    final DateTime today = _day(_clock());
    final DateTime tomorrow = _nextDay(today);
    final (DateTime from, DateTime to) = switch (state.period) {
      SalesPeriod.today => (today, tomorrow),
      SalesPeriod.yesterday => (_previousDay(today), today),
      SalesPeriod.last7Days => (
        DateTime(today.year, today.month, today.day - 6),
        tomorrow,
      ),
      SalesPeriod.custom => (
        state.customFrom ?? today,
        _nextDay(state.customTo ?? today),
      ),
    };
    return SaleQuery(from: from, to: to, paymentMethod: state.paymentMethod);
  }

  static DateTime _day(DateTime moment) =>
      DateTime(moment.year, moment.month, moment.day);

  // Calendar arithmetic, safe across daylight saving changes.
  static DateTime _nextDay(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1);

  static DateTime _previousDay(DateTime day) =>
      DateTime(day.year, day.month, day.day - 1);
}

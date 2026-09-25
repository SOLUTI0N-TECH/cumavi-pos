import 'package:equatable/equatable.dart';

import '../../../sales/domain/entities/daily_sales_summary.dart';
import 'cash_session.dart';

/// Everything the close-drawer screen needs: the open session, the sales made
/// during it and the resulting cash expectation.
final class CashCloseSummary extends Equatable {
  const CashCloseSummary({required this.session, required this.sales});

  final CashSession session;
  final DailySalesSummary sales;

  /// Opening float plus the cash taken during the session.
  double get expectedCash => session.openingAmount + sales.cashTotal;

  /// `counted - expected`: negative means missing money.
  double? differenceFor(double? countedCash) =>
      countedCash == null ? null : countedCash - expectedCash;

  @override
  List<Object?> get props => <Object?>[session, sales];
}

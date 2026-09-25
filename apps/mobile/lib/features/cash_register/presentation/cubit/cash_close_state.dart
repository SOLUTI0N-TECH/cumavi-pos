import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/cash_close_summary.dart';

enum CashCloseStatus { loading, ready, submitting, closed, failure }

final class CashCloseState extends Equatable {
  const CashCloseState({
    this.status = CashCloseStatus.loading,
    this.summary,
    this.countedAmount,
    this.note = '',
    this.failure,
  });

  final CashCloseStatus status;
  final CashCloseSummary? summary;

  /// What the cashier counted, `null` until they type an amount.
  final double? countedAmount;
  final String note;
  final Failure? failure;

  /// `counted - expected`, `null` while there is nothing to compare.
  double? get difference => summary?.differenceFor(countedAmount);

  bool get hasDifference => difference != null && difference!.abs() >= 0.01;

  bool get canSubmit =>
      summary != null &&
      countedAmount != null &&
      status != CashCloseStatus.submitting;

  CashCloseState copyWith({
    CashCloseStatus? status,
    CashCloseSummary? summary,
    double? countedAmount,
    String? note,
    Failure? failure,
  }) {
    return CashCloseState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      countedAmount: countedAmount ?? this.countedAmount,
      note: note ?? this.note,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    summary,
    countedAmount,
    note,
    failure,
  ];
}

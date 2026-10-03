import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_return.dart';
import '../../domain/usecases/cancel_and_return.dart';
import '../../domain/usecases/get_sales.dart';

enum ReturnSaleStatus { loading, editing, saving, saved, failure }

final class ReturnSaleState extends Equatable {
  const ReturnSaleState({
    this.status = ReturnSaleStatus.loading,
    this.sale,
    this.quantities = const <int, int>{},
    this.restock = const <int, bool>{},
    this.refundMethod,
    this.reason = '',
    this.saved,
    this.failure,
  });

  final ReturnSaleStatus status;
  final Sale? sale;

  /// Units to return per line index.
  final Map<int, int> quantities;

  /// Whether each line's units go back to stock (on unless turned off).
  final Map<int, bool> restock;
  final PaymentMethod? refundMethod;
  final String reason;

  /// The stored return, once saved.
  final SaleReturn? saved;
  final Failure? failure;

  int quantityOf(int index) => quantities[index] ?? 0;

  bool restocks(int index) => restock[index] ?? true;

  int get units =>
      quantities.values.fold(0, (int sum, int quantity) => sum + quantity);

  /// What will be refunded, discount prorated.
  double get refund {
    final Sale? sale = this.sale;
    if (sale == null) return 0;
    return quantities.entries.fold(
      0,
      (double sum, MapEntry<int, int> entry) =>
          sum + sale.refundFor(entry.key, entry.value),
    );
  }

  bool get canSubmit =>
      status == ReturnSaleStatus.editing &&
      units > 0 &&
      refundMethod != null &&
      reason.trim().isNotEmpty;

  ReturnSaleState copyWith({
    ReturnSaleStatus? status,
    Sale? sale,
    Map<int, int>? quantities,
    Map<int, bool>? restock,
    PaymentMethod? refundMethod,
    String? reason,
    SaleReturn? saved,
    Failure? failure,
  }) => ReturnSaleState(
    status: status ?? this.status,
    sale: sale ?? this.sale,
    quantities: quantities ?? this.quantities,
    restock: restock ?? this.restock,
    refundMethod: refundMethod ?? this.refundMethod,
    reason: reason ?? this.reason,
    saved: saved ?? this.saved,
    failure: failure,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    sale,
    quantities,
    restock,
    refundMethod,
    reason,
    saved,
    failure,
  ];
}

/// "Devolver": pick the units that came back, whether they can be sold
/// again, how the money goes back and why.
class ReturnSaleCubit extends Cubit<ReturnSaleState> {
  ReturnSaleCubit({
    required GetSale getSale,
    required RegisterReturn registerReturn,
    required String saleId,
  }) : _getSale = getSale,
       _registerReturn = registerReturn,
       _saleId = saleId,
       super(const ReturnSaleState());

  final GetSale _getSale;
  final RegisterReturn _registerReturn;
  final String _saleId;

  Future<void> load() async {
    switch (await _getSale(_saleId)) {
      case Success<Sale>(:final Sale value):
        emit(
          ReturnSaleState(
            status: ReturnSaleStatus.editing,
            sale: value,
            // The money usually goes back the way it came.
            refundMethod: value.paymentMethod,
          ),
        );
      case Failed<Sale>(:final failure):
        emit(
          ReturnSaleState(status: ReturnSaleStatus.failure, failure: failure),
        );
    }
  }

  void increment(int index) {
    final Sale? sale = state.sale;
    if (sale == null) return;
    final int next = state.quantityOf(index) + 1;
    if (next > sale.returnableQuantity(index)) return;
    _setQuantity(index, next);
  }

  void decrement(int index) {
    final int next = state.quantityOf(index) - 1;
    if (next < 0) return;
    _setQuantity(index, next);
  }

  void restockChanged(int index, {required bool restock}) => emit(
    state.copyWith(restock: <int, bool>{...state.restock, index: restock}),
  );

  void refundMethodSelected(PaymentMethod method) =>
      emit(state.copyWith(refundMethod: method));

  void reasonChanged(String reason) => emit(state.copyWith(reason: reason));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: ReturnSaleStatus.saving));
    final Result<SaleReturn> result = await _registerReturn(
      SaleReturnRequest(
        saleId: _saleId,
        refundMethod: state.refundMethod!,
        reason: state.reason,
        items: <ReturnItem>[
          for (final MapEntry<int, int> entry in state.quantities.entries)
            if (entry.value > 0)
              ReturnItem(
                lineIndex: entry.key,
                quantity: entry.value,
                restock: state.restocks(entry.key),
              ),
        ],
      ),
    );
    switch (result) {
      case Success<SaleReturn>(:final SaleReturn value):
        emit(state.copyWith(status: ReturnSaleStatus.saved, saved: value));
      case Failed<SaleReturn>(:final failure):
        emit(
          state.copyWith(status: ReturnSaleStatus.editing, failure: failure),
        );
    }
  }

  void _setQuantity(int index, int quantity) => emit(
    state.copyWith(
      quantities: <int, int>{...state.quantities, index: quantity},
    ),
  );
}

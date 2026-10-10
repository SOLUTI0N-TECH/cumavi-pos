import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/import_order.dart';

enum ImportOrderStatus { idle, importing, imported, failure }

final class ImportOrderState extends Equatable {
  const ImportOrderState({
    this.status = ImportOrderStatus.idle,
    this.order,
    this.failure,
  });

  final ImportOrderStatus status;

  /// The order in the inbox, once imported.
  final Order? order;
  final Failure? failure;

  @override
  List<Object?> get props => <Object?>[status, order, failure];
}

/// "Importar pedido": a web order arrives by the link in its WhatsApp
/// message, pasted or opened on the phone.
class ImportOrderCubit extends Cubit<ImportOrderState> {
  ImportOrderCubit(this._importOrder) : super(const ImportOrderState());

  final ImportOrder _importOrder;

  Future<void> import(String linkOrMessage) async {
    emit(const ImportOrderState(status: ImportOrderStatus.importing));
    final Result<Order> result = await _importOrder(linkOrMessage);
    if (isClosed) return;
    emit(switch (result) {
      Success<Order>(:final Order value) => ImportOrderState(
        status: ImportOrderStatus.imported,
        order: value,
      ),
      Failed<Order>(:final failure) => ImportOrderState(
        status: ImportOrderStatus.failure,
        failure: failure,
      ),
    });
  }
}

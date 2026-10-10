import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/services/external_launcher.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_requests.dart';
import '../../domain/usecases/order_usecases.dart';

enum OrderDetailStatus { loading, ready, failure }

final class OrderDetailState extends Equatable {
  const OrderDetailState({
    this.status = OrderDetailStatus.loading,
    this.order,
    this.busy = false,
    this.failure,
  });

  final OrderDetailStatus status;
  final Order? order;

  /// A change is being saved.
  final bool busy;
  final Failure? failure;

  @override
  List<Object?> get props => <Object?>[status, order, busy, failure];
}

/// One order with its actions: confirm, mark ready, edit, cancel and charge.
/// Actions return the failure (or `null`) so the screen can answer.
class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit({
    required GetOrder getOrder,
    required WatchOrders watchOrders,
    required UpdateOrderStatus updateOrderStatus,
    required EditOrder editOrder,
    required PrepareOrderCheckout prepareOrderCheckout,
    required ExternalLauncher launcher,
    required String orderId,
  }) : _getOrder = getOrder,
       _launcher = launcher,
       _updateOrderStatus = updateOrderStatus,
       _editOrder = editOrder,
       _prepareOrderCheckout = prepareOrderCheckout,
       _orderId = orderId,
       super(const OrderDetailState()) {
    // Another device (or the checkout) may change it meanwhile.
    _subscription = watchOrders()
        .where((OrderEvent event) => event.order.id == orderId)
        .listen((OrderEvent event) => _show(event.order));
  }

  final GetOrder _getOrder;
  final UpdateOrderStatus _updateOrderStatus;
  final EditOrder _editOrder;
  final PrepareOrderCheckout _prepareOrderCheckout;
  final ExternalLauncher _launcher;
  final String _orderId;
  late final StreamSubscription<OrderEvent> _subscription;

  Future<void> load() async {
    final Result<Order> result = await _getOrder(_orderId);
    if (isClosed) return;
    switch (result) {
      case Success<Order>(:final Order value):
        _show(value);
      case Failed<Order>(:final failure):
        emit(
          OrderDetailState(
            status: OrderDetailStatus.failure,
            order: state.order,
            failure: failure,
          ),
        );
    }
  }

  Future<Failure?> confirm({double? deliveryFee}) => _run(
    () => _updateOrderStatus(
      OrderStatusRequest(
        orderId: _orderId,
        update: OrderStatusUpdate(
          to: OrderStatus.confirmed,
          deliveryFee: deliveryFee,
        ),
      ),
    ),
  );

  Future<Failure?> markReady() => _run(
    () => _updateOrderStatus(
      OrderStatusRequest(
        orderId: _orderId,
        update: const OrderStatusUpdate(to: OrderStatus.ready),
      ),
    ),
  );

  Future<Failure?> cancel(String reason) => _run(
    () => _updateOrderStatus(
      OrderStatusRequest(
        orderId: _orderId,
        update: OrderStatusUpdate(to: OrderStatus.cancelled, note: reason),
      ),
    ),
  );

  Future<Failure?> edit(OrderEdit edit) =>
      _run(() => _editOrder(OrderEditRequest(orderId: _orderId, edit: edit)));

  /// The cart for "Cobrar pedido", or why it can't be charged now.
  Future<Result<OrderCheckout>> prepareCheckout() async {
    _setBusy(true);
    final Result<OrderCheckout> result = await _prepareOrderCheckout(_orderId);
    _setBusy(false);
    return result;
  }

  /// Opens the customer's chat with [message] typed.
  Future<Failure?> messageCustomer(String message) async {
    final Order? order = state.order;
    if (order == null) return null;
    return (await _launcher.openWhatsApp(
      phone: order.customer.phone,
      message: message,
    )).failureOrNull;
  }

  Future<Failure?> callCustomer() async {
    final Order? order = state.order;
    if (order == null) return null;
    return (await _launcher.callPhone(order.customer.phone)).failureOrNull;
  }

  Future<Failure?> _run(Future<Result<Order>> Function() action) async {
    _setBusy(true);
    final Result<Order> result = await action();
    if (isClosed) return result.failureOrNull;
    switch (result) {
      case Success<Order>(:final Order value):
        _show(value);
        return null;
      case Failed<Order>(:final failure):
        _setBusy(false);
        return failure;
    }
  }

  void _show(Order order) {
    if (isClosed) return;
    emit(OrderDetailState(status: OrderDetailStatus.ready, order: order));
  }

  void _setBusy(bool busy) {
    if (isClosed) return;
    emit(
      OrderDetailState(
        status: state.status,
        order: state.order,
        busy: busy,
        failure: state.failure,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

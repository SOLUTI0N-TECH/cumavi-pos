import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_requests.dart';
import '../../domain/usecases/order_usecases.dart';

/// Tabs of the inbox.
enum OrdersFilter {
  newOrders(<OrderStatus>{OrderStatus.newOrder}),
  inProgress(<OrderStatus>{OrderStatus.confirmed, OrderStatus.ready}),
  delivered(<OrderStatus>{OrderStatus.delivered}),
  cancelled(<OrderStatus>{OrderStatus.cancelled});

  const OrdersFilter(this.statuses);

  final Set<OrderStatus> statuses;
}

enum OrdersInboxStatus { loading, ready, failure }

final class OrdersInboxState extends Equatable {
  const OrdersInboxState({
    this.status = OrdersInboxStatus.loading,
    this.filter = OrdersFilter.newOrders,
    this.orders = const <Order>[],
    this.simulating = false,
    this.failure,
  });

  final OrdersInboxStatus status;
  final OrdersFilter filter;

  /// Every order, newest first.
  final List<Order> orders;
  final bool simulating;
  final Failure? failure;

  List<Order> get visible => orders
      .where((Order order) => filter.statuses.contains(order.status))
      .toList();

  int countOf(OrdersFilter filter) => orders
      .where((Order order) => filter.statuses.contains(order.status))
      .length;

  OrdersInboxState copyWith({
    OrdersInboxStatus? status,
    OrdersFilter? filter,
    List<Order>? orders,
    bool? simulating,
    Failure? failure,
  }) => OrdersInboxState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    orders: orders ?? this.orders,
    simulating: simulating ?? this.simulating,
    failure: failure,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    filter,
    orders,
    simulating,
    failure,
  ];
}

/// "Pedidos": the branch's orders by tab, refreshed as they change.
class OrdersInboxCubit extends Cubit<OrdersInboxState> {
  OrdersInboxCubit({
    required GetOrders getOrders,
    required WatchOrders watchOrders,
    required SimulateIncomingOrder simulateIncomingOrder,
  }) : _getOrders = getOrders,
       _simulateIncomingOrder = simulateIncomingOrder,
       super(const OrdersInboxState()) {
    _subscription = watchOrders().listen((_) => load());
  }

  final GetOrders _getOrders;
  final SimulateIncomingOrder _simulateIncomingOrder;
  late final StreamSubscription<OrderEvent> _subscription;

  Future<void> load() async {
    final Result<List<Order>> result = await _getOrders(const OrderQuery());
    if (isClosed) return;
    switch (result) {
      case Success<List<Order>>(:final List<Order> value):
        emit(state.copyWith(status: OrdersInboxStatus.ready, orders: value));
      case Failed<List<Order>>(:final failure):
        emit(
          state.copyWith(status: OrdersInboxStatus.failure, failure: failure),
        );
    }
  }

  void filterSelected(OrdersFilter filter) =>
      emit(state.copyWith(filter: filter));

  /// Brings in a demo order and shows the "Nuevos" tab. Returns the failure
  /// (e.g. the store is disabled), or `null`.
  Future<Failure?> simulateNewOrder() async {
    emit(state.copyWith(simulating: true));
    final Result<Order> result = await _simulateIncomingOrder(const NoParams());
    if (isClosed) return result.failureOrNull;
    emit(
      state.copyWith(
        simulating: false,
        filter: result.failureOrNull == null ? OrdersFilter.newOrders : null,
      ),
    );
    return result.failureOrNull;
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_requests.dart';
import '../../domain/usecases/order_usecases.dart';

final class OrdersBadgeState extends Equatable {
  const OrdersBadgeState({
    this.newCount = 0,
    this.inProgressCount = 0,
    this.arrived,
    this.arrivals = 0,
  });

  /// Orders waiting to be confirmed.
  final int newCount;

  /// Confirmed or ready, not charged yet.
  final int inProgressCount;

  /// The last order that arrived while the app was open.
  final Order? arrived;

  /// Counts arrivals, so the same order announced twice is still a change.
  final int arrivals;

  bool get hasOpenOrders => newCount + inProgressCount > 0;

  @override
  List<Object?> get props => <Object?>[
    newCount,
    inProgressCount,
    arrived,
    arrivals,
  ];
}

/// Session-wide counter of open orders for Inicio's badge, and the source
/// of the "new order" alert. It listens to the order events (the branch's
/// socket once the API exists).
class OrdersBadgeCubit extends Cubit<OrdersBadgeState> {
  OrdersBadgeCubit({
    required GetOrders getOrders,
    required WatchOrders watchOrders,
  }) : _getOrders = getOrders,
       super(const OrdersBadgeState()) {
    _subscription = watchOrders().listen(_onEvent);
  }

  static const OrderQuery _openOrders = OrderQuery(
    statuses: <OrderStatus>{
      OrderStatus.newOrder,
      OrderStatus.confirmed,
      OrderStatus.ready,
    },
  );

  final GetOrders _getOrders;
  late final StreamSubscription<OrderEvent> _subscription;

  Future<void> load() async {
    final Result<List<Order>> result = await _getOrders(_openOrders);
    final List<Order>? orders = result.valueOrNull;
    if (orders == null || isClosed) return;
    emit(
      OrdersBadgeState(
        newCount: orders
            .where((Order order) => order.status == OrderStatus.newOrder)
            .length,
        inProgressCount: orders
            .where((Order order) => order.status != OrderStatus.newOrder)
            .length,
        arrived: state.arrived,
        arrivals: state.arrivals,
      ),
    );
  }

  Future<void> _onEvent(OrderEvent event) async {
    if (event is OrderCreated && !isClosed) {
      emit(
        OrdersBadgeState(
          newCount: state.newCount,
          inProgressCount: state.inProgressCount,
          arrived: event.order,
          arrivals: state.arrivals + 1,
        ),
      );
    }
    await load();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

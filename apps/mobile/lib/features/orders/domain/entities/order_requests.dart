import 'package:equatable/equatable.dart';

import 'order.dart';

/// Filters of the orders inbox; `null` statuses means every order.
final class OrderQuery extends Equatable {
  const OrderQuery({this.statuses});

  final Set<OrderStatus>? statuses;

  bool matches(Order order) =>
      statuses == null || statuses!.contains(order.status);

  @override
  List<Object?> get props => <Object?>[statuses];
}

/// `POST /orders/{id}/status`: the next state, with the cancel reason or
/// the delivery fee set when confirming.
final class OrderStatusUpdate extends Equatable {
  const OrderStatusUpdate({required this.to, this.note, this.deliveryFee});

  final OrderStatus to;
  final String? note;

  /// Only when confirming a delivery order.
  final double? deliveryFee;

  @override
  List<Object?> get props => <Object?>[to, note, deliveryFee];
}

/// `PATCH /orders/{id}` (`ECO-R10`): new quantities per line position (0
/// removes the line) and the delivery fee.
final class OrderEdit extends Equatable {
  const OrderEdit({required this.quantities, required this.deliveryFee});

  /// One per current line, in order.
  final List<int> quantities;
  final double deliveryFee;

  @override
  List<Object?> get props => <Object?>[quantities, deliveryFee];
}

/// What changed in the orders, as the backend's socket will push it.
sealed class OrderEvent extends Equatable {
  const OrderEvent(this.order);

  final Order order;

  @override
  List<Object?> get props => <Object?>[order];
}

/// A new order arrived (`order.created`).
final class OrderCreated extends OrderEvent {
  const OrderCreated(super.order);
}

/// An order changed state or was edited (`order.updated`).
final class OrderUpdated extends OrderEvent {
  const OrderUpdated(super.order);
}

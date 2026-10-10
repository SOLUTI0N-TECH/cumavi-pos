import '../../../../core/error/failure.dart';
import '../entities/order.dart';

/// Order rules shared by the use cases (to enforce them) and the screens
/// (to offer only what is allowed).
abstract final class OrderRules {
  /// `ECO-R8`. `delivered` is not here: only charging the order reaches it
  /// (`ECO-R9`).
  static const Map<OrderStatus, Set<OrderStatus>> _manualTransitions =
      <OrderStatus, Set<OrderStatus>>{
        OrderStatus.newOrder: <OrderStatus>{
          OrderStatus.confirmed,
          OrderStatus.cancelled,
        },
        OrderStatus.confirmed: <OrderStatus>{
          OrderStatus.ready,
          OrderStatus.cancelled,
        },
        OrderStatus.ready: <OrderStatus>{OrderStatus.cancelled},
      };

  static bool canMoveTo(Order order, OrderStatus to) =>
      _manualTransitions[order.status]?.contains(to) ?? false;

  /// The next step the inbox offers as the main button, if any.
  static OrderStatus? nextStep(Order order) => switch (order.status) {
    OrderStatus.newOrder => OrderStatus.confirmed,
    OrderStatus.confirmed => OrderStatus.ready,
    _ => null,
  };

  /// `ECO-R10`: quantities, lines and delivery fee change only before the
  /// order is ready.
  static bool canEdit(Order order) =>
      order.status == OrderStatus.newOrder ||
      order.status == OrderStatus.confirmed;

  /// `ECO-R9`: an order is charged once it is ready.
  static bool canCheckout(Order order) => order.status == OrderStatus.ready;

  static bool canCancel(Order order) => canMoveTo(order, OrderStatus.cancelled);

  static Failure? checkTransition(Order order, OrderStatus to) =>
      canMoveTo(order, to)
      ? null
      : const ConflictFailure(FailureCode.invalidOrderTransition);

  static Failure? checkDeliveryFee(double? fee) => fee != null && fee < 0
      ? const ValidationFailure(FailureCode.invalidDeliveryFee)
      : null;
}

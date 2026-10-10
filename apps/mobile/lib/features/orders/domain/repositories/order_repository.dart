import '../../../../core/utils/result.dart';
import '../entities/order.dart';
import '../entities/order_requests.dart';

/// The orders of the active branch. Mocked in memory while the API (backend
/// phase B7) is not connected; the shape follows `docs/modulos/ecommerce.md`.
abstract interface class OrderRepository {
  /// `GET /orders`: newest first.
  Future<Result<List<Order>>> getOrders(OrderQuery query);

  /// `GET /orders/{id}`, with its history.
  Future<Result<Order>> getOrder(String id);

  /// Orders created or changed, from this device or another one (the
  /// socket of the branch).
  Stream<OrderEvent> watch();

  /// `POST /orders/{id}/status`. The transition is checked before calling.
  Future<Result<Order>> changeStatus(String id, OrderStatusUpdate update);

  /// `PATCH /orders/{id}`.
  Future<Result<Order>> editOrder(String id, OrderEdit edit);

  /// Part of `POST /orders/{id}/checkout`: links the sale and marks the
  /// order delivered.
  Future<Result<Order>> markDelivered(String id, {required String saleId});

  /// Stores an order that came in a WhatsApp link; importing the same order
  /// twice returns the one already stored.
  Future<Result<Order>> importOrder(Order order);
}

/// Brings in a realistic order, so the inbox can be tried while nothing
/// arrives from the web. Only the mock implements it.
abstract interface class DemoOrderSimulator {
  Future<Result<Order>> simulateNewOrder();
}

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../../../online_store/domain/entities/store_settings.dart';
import '../../../online_store/domain/repositories/store_settings_repository.dart';
import '../../../sales/domain/entities/cart.dart';
import '../../../sales/domain/entities/cart_line.dart';
import '../../../sales/domain/entities/sale.dart';
import '../../../sales/domain/entities/sale_draft.dart';
import '../entities/order.dart';
import '../entities/order_requests.dart';
import '../repositories/order_repository.dart';
import 'order_rules.dart';

/// The inbox: orders of the branch, newest first.
final class GetOrders implements UseCase<List<Order>, OrderQuery> {
  const GetOrders(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<List<Order>>> call(OrderQuery input) =>
      _repository.getOrders(input);
}

final class GetOrder implements UseCase<Order, String> {
  const GetOrder(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(String orderId) => _repository.getOrder(orderId);
}

/// Orders created or changed anywhere, to refresh the screens and the badge.
final class WatchOrders {
  const WatchOrders(this._repository);

  final OrderRepository _repository;

  Stream<OrderEvent> call() => _repository.watch();
}

/// Input of [UpdateOrderStatus].
final class OrderStatusRequest {
  const OrderStatusRequest({required this.orderId, required this.update});

  final String orderId;
  final OrderStatusUpdate update;
}

/// Confirms, marks ready or cancels an order (`ECO-R8`). Cancelling needs a
/// reason; confirming a delivery can set its fee.
final class UpdateOrderStatus implements UseCase<Order, OrderStatusRequest> {
  const UpdateOrderStatus(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(OrderStatusRequest input) async {
    final OrderStatusUpdate update = input.update;
    final String note = update.note?.trim() ?? '';
    if (update.to == OrderStatus.cancelled && note.isEmpty) {
      return const Failed<Order>(ValidationFailure(FailureCode.reasonRequired));
    }
    final Failure? fee = OrderRules.checkDeliveryFee(update.deliveryFee);
    if (fee != null) return Failed<Order>(fee);

    final Result<Order> current = await _repository.getOrder(input.orderId);
    if (current case Failed<Order>()) return current;
    final Failure? transition = OrderRules.checkTransition(
      current.valueOrNull!,
      update.to,
    );
    if (transition != null) return Failed<Order>(transition);

    return _repository.changeStatus(
      input.orderId,
      OrderStatusUpdate(
        to: update.to,
        note: note.isEmpty ? null : note,
        deliveryFee: update.to == OrderStatus.confirmed
            ? update.deliveryFee
            : null,
      ),
    );
  }
}

/// Input of [EditOrder].
final class OrderEditRequest {
  const OrderEditRequest({required this.orderId, required this.edit});

  final String orderId;
  final OrderEdit edit;
}

/// Changes quantities, removes lines or sets the delivery fee while the
/// order is new or confirmed (`ECO-R10`).
final class EditOrder implements UseCase<Order, OrderEditRequest> {
  const EditOrder(this._repository);

  final OrderRepository _repository;

  @override
  Future<Result<Order>> call(OrderEditRequest input) async {
    final OrderEdit edit = input.edit;
    final Failure? fee = OrderRules.checkDeliveryFee(edit.deliveryFee);
    if (fee != null) return Failed<Order>(fee);
    if (edit.quantities.any((int quantity) => quantity < 0)) {
      return const Failed<Order>(
        ValidationFailure(FailureCode.invalidStockQuantity),
      );
    }
    if (edit.quantities.every((int quantity) => quantity == 0)) {
      return const Failed<Order>(ValidationFailure(FailureCode.orderEmpty));
    }

    final Result<Order> current = await _repository.getOrder(input.orderId);
    if (current case Failed<Order>()) return current;
    final Order order = current.valueOrNull!;
    if (!OrderRules.canEdit(order)) {
      return const Failed<Order>(ConflictFailure(FailureCode.orderNotEditable));
    }
    if (edit.quantities.length != order.lines.length) {
      return const Failed<Order>(
        ValidationFailure(FailureCode.invalidStockQuantity),
      );
    }
    return _repository.editOrder(order.id, edit);
  }
}

/// What "Cobrar pedido" opens: the order and a cart with its lines at the
/// order's prices.
final class OrderCheckout {
  const OrderCheckout({required this.order, required this.cart});

  final Order order;
  final Cart cart;
}

/// Checks a ready order can be charged now (`ECO-R9`): its products still
/// exist and the branch has the stock. The price charged is the order's,
/// not the current one.
final class PrepareOrderCheckout implements UseCase<OrderCheckout, String> {
  const PrepareOrderCheckout({
    required OrderRepository orderRepository,
    required ProductRepository productRepository,
  }) : _orderRepository = orderRepository,
       _productRepository = productRepository;

  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;

  @override
  Future<Result<OrderCheckout>> call(String orderId) async {
    final Result<Order> orderResult = await _orderRepository.getOrder(orderId);
    if (orderResult case Failed<Order>(:final Failure failure)) {
      return Failed<OrderCheckout>(failure);
    }
    final Order order = orderResult.valueOrNull!;
    if (!OrderRules.canCheckout(order)) {
      return const Failed<OrderCheckout>(
        ConflictFailure(FailureCode.invalidOrderTransition),
      );
    }

    final List<CartLine> lines = <CartLine>[];
    for (final OrderLine line in order.lines) {
      final Result<Product> product = await _productRepository.getProductById(
        line.productId,
      );
      if (product case Failed<Product>(:final Failure failure)) {
        return Failed<OrderCheckout>(failure);
      }
      final Product found = product.valueOrNull!;
      final String? variantId = line.variantId;
      final ProductVariant? variant = variantId == null
          ? null
          : found.variantById(variantId);
      final String name = line.variantLabel == null
          ? line.productName
          : '${line.productName} (${line.variantLabel})';
      if (variantId != null && variant == null) {
        return Failed<OrderCheckout>(
          NotFoundFailure(FailureCode.productNotFound, detail: name),
        );
      }
      final int stock = variant?.stockQuantity ?? found.stockQuantity;
      if (stock < line.quantity) {
        return Failed<OrderCheckout>(
          ConflictFailure(FailureCode.insufficientStock, detail: name),
        );
      }
      lines.add(
        CartLine(
          product: found,
          variant: variant,
          quantity: line.quantity,
          fixedUnitPrice: line.unitPrice,
        ),
      );
    }
    return Success<OrderCheckout>(
      OrderCheckout(
        order: order,
        cart: Cart(lines: lines, deliveryFee: order.deliveryFee),
      ),
    );
  }
}

/// "Cobrar pedido": registers the sale with the checkout's payment and marks
/// the order delivered, linked to it (`ECO-R9`). The sale rules apply: an
/// open cash session and enough stock.
final class CheckoutOrder implements UseCase<Sale, SaleDraft> {
  const CheckoutOrder({
    required OrderRepository orderRepository,
    required UseCase<Sale, SaleDraft> registerSale,
    required this.orderId,
  }) : _orderRepository = orderRepository,
       _registerSale = registerSale;

  final OrderRepository _orderRepository;
  final UseCase<Sale, SaleDraft> _registerSale;
  final String orderId;

  @override
  Future<Result<Sale>> call(SaleDraft input) async {
    final Result<Order> orderResult = await _orderRepository.getOrder(orderId);
    if (orderResult case Failed<Order>(:final Failure failure)) {
      return Failed<Sale>(failure);
    }
    final Order order = orderResult.valueOrNull!;
    if (!OrderRules.canCheckout(order)) {
      return const Failed<Sale>(
        ConflictFailure(FailureCode.invalidOrderTransition),
      );
    }

    final Result<Sale> sale = await _registerSale(
      input.forOrder(orderId: order.id, orderNumber: order.number),
    );
    if (sale case Failed<Sale>()) return sale;

    final Result<Order> delivered = await _orderRepository.markDelivered(
      order.id,
      saleId: sale.valueOrNull!.id,
    );
    if (delivered case Failed<Order>(:final Failure failure)) {
      return Failed<Sale>(failure);
    }
    return sale;
  }
}

/// Brings in a demo order. The web wouldn't take orders while the store is
/// disabled, so neither does the demo.
final class SimulateIncomingOrder implements UseCase<Order, NoParams> {
  const SimulateIncomingOrder({
    required DemoOrderSimulator simulator,
    required StoreSettingsRepository storeSettingsRepository,
  }) : _simulator = simulator,
       _storeSettingsRepository = storeSettingsRepository;

  final DemoOrderSimulator _simulator;
  final StoreSettingsRepository _storeSettingsRepository;

  @override
  Future<Result<Order>> call(NoParams input) async {
    final Result<StoreSettings> settings = await _storeSettingsRepository
        .getSettings();
    if (settings case Failed<StoreSettings>(:final Failure failure)) {
      return Failed<Order>(failure);
    }
    if (!settings.valueOrNull!.isEnabled) {
      return const Failed<Order>(ConflictFailure(FailureCode.storeDisabled));
    }
    return _simulator.simulateNewOrder();
  }
}

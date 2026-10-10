import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_requests.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/in_memory_order_data_source.dart';

final class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl({
    required OrderDataSource dataSource,
    required SessionRepository sessionRepository,
  }) : _dataSource = dataSource,
       _sessionRepository = sessionRepository;

  final OrderDataSource _dataSource;
  final SessionRepository _sessionRepository;

  @override
  Future<Result<List<Order>>> getOrders(OrderQuery query) => _call(() async {
    final List<Order> orders =
        (await _dataSource.fetchOrders()).where(query.matches).toList()
          ..sort((Order a, Order b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  });

  @override
  Future<Result<Order>> getOrder(String id) => _call(() async {
    final Order? order = (await _dataSource.fetchOrders())
        .where((Order candidate) => candidate.id == id)
        .firstOrNull;
    if (order == null) {
      throw DataSourceException(FailureCode.orderNotFound, detail: id);
    }
    return order;
  });

  @override
  Stream<OrderEvent> watch() => _dataSource.watch();

  @override
  Future<Result<Order>> changeStatus(String id, OrderStatusUpdate update) =>
      _call(() => _dataSource.changeStatus(id, update, userName: _userName));

  @override
  Future<Result<Order>> editOrder(String id, OrderEdit edit) =>
      _call(() => _dataSource.editOrder(id, edit, userName: _userName));

  @override
  Future<Result<Order>> markDelivered(String id, {required String saleId}) =>
      _call(
        () =>
            _dataSource.markDelivered(id, saleId: saleId, userName: _userName),
      );

  @override
  Future<Result<Order>> importOrder(Order order) =>
      _call(() => _dataSource.importOrder(order));

  String get _userName => _sessionRepository.currentCashierName;

  Future<Result<T>> _call<T>(Future<T> Function() call) async {
    try {
      return Success<T>(await call());
    } on DataSourceException catch (exception) {
      return Failed<T>(switch (exception.code) {
        FailureCode.orderNotFound => NotFoundFailure(
          exception.code,
          detail: exception.detail,
        ),
        _ => ConflictFailure(exception.code, detail: exception.detail),
      });
    }
  }
}

/// The mock's "new order from the web" for the demo inbox.
final class InMemoryDemoOrderSimulator implements DemoOrderSimulator {
  const InMemoryDemoOrderSimulator(this._dataSource);

  final InMemoryOrderDataSource _dataSource;

  @override
  Future<Result<Order>> simulateNewOrder() async =>
      Success<Order>(await _dataSource.simulateNewOrder());
}

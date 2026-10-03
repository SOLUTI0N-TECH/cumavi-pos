import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../inventory/domain/entities/stock_movement.dart';
import '../../../inventory/domain/usecases/stock_usecases.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product.dart';

enum ProductDetailStatus { loading, ready, failure }

final class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.loading,
    this.product,
    this.movements = const <StockMovement>[],
    this.failure,
  });

  final ProductDetailStatus status;
  final Product? product;

  /// The latest stock movements of the product, newest first.
  final List<StockMovement> movements;
  final Failure? failure;

  @override
  List<Object?> get props => <Object?>[status, product, movements, failure];
}

/// Everything about one product, for the inventory's detail screen.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required GetProduct getProduct,
    required GetStockMovements getStockMovements,
    required this.productId,
  }) : _getProduct = getProduct,
       _getStockMovements = getStockMovements,
       super(const ProductDetailState());

  /// How many movements the detail shows before "Ver todos".
  static const int recentMovements = 5;

  final GetProduct _getProduct;
  final GetStockMovements _getStockMovements;
  final String productId;

  /// Also called after editing or moving stock, to show the saved data.
  Future<void> load() async {
    // Keep the current product on screen while refreshing it.
    emit(
      ProductDetailState(product: state.product, movements: state.movements),
    );
    final Result<List<StockMovement>> movements = await _getStockMovements(
      StockMovementQuery(productId: productId, limit: recentMovements),
    );
    switch (await _getProduct(productId)) {
      case Success<Product>(:final Product value):
        emit(
          ProductDetailState(
            status: ProductDetailStatus.ready,
            product: value,
            movements: movements.valueOrNull ?? state.movements,
          ),
        );
      case Failed<Product>(:final failure):
        emit(
          ProductDetailState(
            status: ProductDetailStatus.failure,
            product: state.product,
            movements: state.movements,
            failure: failure,
          ),
        );
    }
  }
}

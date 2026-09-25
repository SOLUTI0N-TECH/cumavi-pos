import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product.dart';

enum ProductDetailStatus { loading, ready, failure }

final class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.loading,
    this.product,
    this.failure,
  });

  final ProductDetailStatus status;
  final Product? product;
  final Failure? failure;

  @override
  List<Object?> get props => <Object?>[status, product, failure];
}

/// Everything about one product, for the inventory's detail screen.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({required GetProduct getProduct, required this.productId})
    : _getProduct = getProduct,
      super(const ProductDetailState());

  final GetProduct _getProduct;
  final String productId;

  /// Also called after editing, to show the saved data.
  Future<void> load() async {
    // Keep the current product on screen while refreshing it.
    emit(ProductDetailState(product: state.product));
    switch (await _getProduct(productId)) {
      case Success<Product>(:final Product value):
        emit(
          ProductDetailState(status: ProductDetailStatus.ready, product: value),
        );
      case Failed<Product>(:final failure):
        emit(
          ProductDetailState(
            status: ProductDetailStatus.failure,
            product: state.product,
            failure: failure,
          ),
        );
    }
  }
}

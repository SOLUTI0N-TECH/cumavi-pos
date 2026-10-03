import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/domain/usecases/get_product.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/stock_usecases.dart';

enum AdjustStockStatus { loading, editing, saving, saved, failure }

final class AdjustStockState extends Equatable {
  const AdjustStockState({
    this.status = AdjustStockStatus.loading,
    this.product,
    this.variantId,
    this.mode = AdjustmentMode.count,
    this.quantity,
    this.reason = AdjustmentReason.count,
    this.note = '',
    this.failure,
  });

  final AdjustStockStatus status;
  final Product? product;

  /// The variant being adjusted; required when the product has variants.
  final String? variantId;
  final AdjustmentMode mode;

  /// Units counted, added or removed; `null` while the field is empty.
  final int? quantity;
  final AdjustmentReason? reason;
  final String note;
  final Failure? failure;

  ProductVariant? get variant {
    final String? id = variantId;
    return id == null ? null : product?.variantById(id);
  }

  int get currentStock => variant?.stockQuantity ?? product?.stockQuantity ?? 0;

  /// The change the adjustment would make, `0` until it has a quantity.
  int get delta {
    final int? quantity = this.quantity;
    if (quantity == null) return 0;
    return StockAdjustment(
      productId: '',
      mode: mode,
      quantity: quantity,
      reason: reason,
    ).deltaFrom(currentStock);
  }

  int get newStock => currentStock + delta;

  bool get canSubmit =>
      status == AdjustStockStatus.editing &&
      (product?.hasVariants != true || variant != null) &&
      reason != null &&
      delta != 0 &&
      newStock >= 0;

  AdjustStockState copyWith({
    AdjustStockStatus? status,
    Product? product,
    String? variantId,
    AdjustmentMode? mode,
    AdjustmentReason? reason,
    String? note,
    Failure? failure,
  }) => AdjustStockState(
    status: status ?? this.status,
    product: product ?? this.product,
    variantId: variantId ?? this.variantId,
    mode: mode ?? this.mode,
    quantity: quantity,
    reason: reason ?? this.reason,
    note: note ?? this.note,
    failure: failure,
  );

  /// Same state with another quantity; `null` empties the field.
  AdjustStockState withQuantity(int? quantity) => AdjustStockState(
    status: status,
    product: product,
    variantId: variantId,
    mode: mode,
    quantity: quantity,
    reason: reason,
    note: note,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    product,
    variantId,
    mode,
    quantity,
    reason,
    note,
    failure,
  ];
}

/// "Ajustar stock": count, add or remove units of a product or variant.
class AdjustStockCubit extends Cubit<AdjustStockState> {
  AdjustStockCubit({
    required GetProduct getProduct,
    required AdjustStock adjustStock,
    required String productId,
    String? variantId,
  }) : _getProduct = getProduct,
       _adjustStock = adjustStock,
       _productId = productId,
       _initialVariantId = variantId,
       super(const AdjustStockState());

  final GetProduct _getProduct;
  final AdjustStock _adjustStock;
  final String _productId;
  final String? _initialVariantId;

  Future<void> load() async {
    switch (await _getProduct(_productId)) {
      case Success<Product>(:final Product value):
        emit(
          AdjustStockState(
            status: AdjustStockStatus.editing,
            product: value,
            variantId:
                _initialVariantId ??
                (value.hasVariants ? value.variants.first.id : null),
          ),
        );
      case Failed<Product>(:final failure):
        emit(
          AdjustStockState(status: AdjustStockStatus.failure, failure: failure),
        );
    }
  }

  void variantSelected(String variantId) =>
      emit(state.copyWith(variantId: variantId));

  /// Counting suggests the "Conteo" reason; adding or removing asks for one.
  void modeSelected(AdjustmentMode mode) {
    if (mode == state.mode) return;
    emit(
      AdjustStockState(
        status: state.status,
        product: state.product,
        variantId: state.variantId,
        mode: mode,
        reason: mode == AdjustmentMode.count ? AdjustmentReason.count : null,
        note: state.note,
      ),
    );
  }

  void quantityChanged(int? quantity) => emit(
    state.withQuantity(quantity == null || quantity < 0 ? null : quantity),
  );

  void reasonSelected(AdjustmentReason reason) =>
      emit(state.copyWith(reason: reason));

  void noteChanged(String note) => emit(state.copyWith(note: note));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: AdjustStockStatus.saving));
    final Result<StockMovement> result = await _adjustStock(
      StockAdjustment(
        productId: _productId,
        variantId: state.variantId,
        mode: state.mode,
        quantity: state.quantity!,
        reason: state.reason,
        note: state.note,
      ),
    );
    switch (result) {
      case Success<StockMovement>():
        emit(state.copyWith(status: AdjustStockStatus.saved));
      case Failed<StockMovement>(:final failure):
        emit(
          state.copyWith(status: AdjustStockStatus.editing, failure: failure),
        );
    }
  }
}

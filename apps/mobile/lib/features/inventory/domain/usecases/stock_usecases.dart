import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../entities/stock_movement.dart';
import '../repositories/inventory_repository.dart';

/// One product (or variant) of a goods receipt.
final class ReceivingLine {
  const ReceivingLine({
    required this.productId,
    required this.quantity,
    this.variantId,
    this.unitCost,
  });

  final String productId;
  final String? variantId;
  final int quantity;
  final double? unitCost;
}

/// Goods received at once, e.g. from one supplier.
final class GoodsReceipt {
  const GoodsReceipt({required this.lines, this.note});

  final List<ReceivingLine> lines;

  /// The supplier or any remark; copied to every line.
  final String? note;
}

/// "Ingreso de mercadería": adds the received units as purchase movements.
final class ReceiveStock implements UseCase<List<StockMovement>, GoodsReceipt> {
  const ReceiveStock(this._repository);

  final InventoryRepository _repository;

  @override
  Future<Result<List<StockMovement>>> call(GoodsReceipt input) async {
    if (input.lines.isEmpty) {
      return const Failed<List<StockMovement>>(
        ValidationFailure(FailureCode.emptyGoodsReceipt),
      );
    }
    for (final ReceivingLine line in input.lines) {
      if (line.quantity <= 0) {
        return const Failed<List<StockMovement>>(
          ValidationFailure(FailureCode.invalidStockQuantity),
        );
      }
      if ((line.unitCost ?? 0) < 0) {
        return const Failed<List<StockMovement>>(
          ValidationFailure(FailureCode.negativeCostPrice),
        );
      }
    }
    final String? note = _clean(input.note);
    return _repository.recordMovements(<StockMovementDraft>[
      for (final ReceivingLine line in input.lines)
        StockMovementDraft(
          productId: line.productId,
          variantId: line.variantId,
          delta: line.quantity,
          type: StockMovementType.purchase,
          unitCost: line.unitCost,
          note: note,
        ),
    ]);
  }
}

/// How an adjustment reads its quantity.
enum AdjustmentMode {
  /// Units found or returned to the shelf.
  add,

  /// Units taken out (damaged, lost…).
  remove,

  /// The units counted on the shelf; the difference is recorded.
  count,
}

/// "Ajustar stock" of a product or one of its variants.
final class StockAdjustment {
  const StockAdjustment({
    required this.productId,
    required this.mode,
    required this.quantity,
    required this.reason,
    this.variantId,
    this.note,
  });

  final String productId;
  final String? variantId;
  final AdjustmentMode mode;

  /// Units to add or remove, or the counted stock.
  final int quantity;
  final AdjustmentReason? reason;
  final String? note;

  /// Change the adjustment makes on a stock of [current] units.
  int deltaFrom(int current) => switch (mode) {
    AdjustmentMode.add => quantity,
    AdjustmentMode.remove => -quantity,
    AdjustmentMode.count => quantity - current,
  };
}

/// Records an adjustment with its reason. A count that matches the stock
/// changes nothing and is refused, so the history only shows real changes.
final class AdjustStock implements UseCase<StockMovement, StockAdjustment> {
  const AdjustStock({
    required InventoryRepository inventoryRepository,
    required ProductRepository productRepository,
  }) : _inventoryRepository = inventoryRepository,
       _productRepository = productRepository;

  final InventoryRepository _inventoryRepository;
  final ProductRepository _productRepository;

  @override
  Future<Result<StockMovement>> call(StockAdjustment input) async {
    final AdjustmentReason? reason = input.reason;
    if (reason == null) {
      return const Failed<StockMovement>(
        ValidationFailure(FailureCode.adjustmentReasonRequired),
      );
    }
    if (input.quantity < 0 ||
        (input.mode != AdjustmentMode.count && input.quantity == 0)) {
      return const Failed<StockMovement>(
        ValidationFailure(FailureCode.invalidStockQuantity),
      );
    }

    final Result<Product> productResult = await _productRepository
        .getProductById(input.productId);
    if (productResult case Failed<Product>(:final Failure failure)) {
      return Failed<StockMovement>(failure);
    }
    final Product product = productResult.valueOrNull!;
    final String? variantId = input.variantId;
    final ProductVariant? variant = variantId == null
        ? null
        : product.variantById(variantId);
    if (variantId != null && variant == null) {
      return const Failed<StockMovement>(
        NotFoundFailure(FailureCode.productNotFound),
      );
    }

    final int delta = input.deltaFrom(
      variant?.stockQuantity ?? product.stockQuantity,
    );
    if (delta == 0) {
      return const Failed<StockMovement>(
        ValidationFailure(FailureCode.noStockChange),
      );
    }
    final Result<List<StockMovement>> recorded = await _inventoryRepository
        .recordMovements(<StockMovementDraft>[
          StockMovementDraft(
            productId: product.id,
            variantId: variantId,
            delta: delta,
            type: StockMovementType.adjustment,
            reason: reason,
            note: _clean(input.note),
          ),
        ]);
    return switch (recorded) {
      Success<List<StockMovement>>(:final List<StockMovement> value) =>
        Success<StockMovement>(value.single),
      Failed<List<StockMovement>>(:final Failure failure) =>
        Failed<StockMovement>(failure),
    };
  }
}

/// Movements of the history screens.
final class GetStockMovements
    implements UseCase<List<StockMovement>, StockMovementQuery> {
  const GetStockMovements(this._repository);

  final InventoryRepository _repository;

  @override
  Future<Result<List<StockMovement>>> call(StockMovementQuery input) =>
      _repository.getMovements(input);
}

String? _clean(String? note) {
  final String trimmed = note?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

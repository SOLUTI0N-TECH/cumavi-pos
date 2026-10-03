import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../inventory/domain/entities/stock_movement.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../entities/product.dart';
import '../entities/product_draft.dart';
import '../entities/product_variant.dart';
import '../repositories/product_repository.dart';
import 'product_draft_rules.dart';

/// Validates the product form and stores the new product. Its units enter
/// the stock as "Inventario inicial" movements, so the history starts at
/// the product's first day.
final class CreateProduct implements UseCase<Product, ProductDraft> {
  const CreateProduct({
    required ProductRepository productRepository,
    required InventoryRepository inventoryRepository,
  }) : _productRepository = productRepository,
       _inventoryRepository = inventoryRepository;

  final ProductRepository _productRepository;
  final InventoryRepository _inventoryRepository;

  @override
  Future<Result<Product>> call(ProductDraft input) async {
    final Failure? validation = ProductDraftRules.validate(input);
    if (validation != null) return Failed<Product>(validation);

    final Result<Product> created = await _productRepository.createProduct(
      input.withoutStock(),
    );
    if (created case Failed<Product>()) return created;
    final Product product = created.valueOrNull!;

    final List<StockMovementDraft> initial = <StockMovementDraft>[
      if (!input.hasVariants && input.stockQuantity > 0)
        StockMovementDraft(
          productId: product.id,
          delta: input.stockQuantity,
          type: StockMovementType.initial,
        ),
      for (final ProductVariant variant in input.variants)
        if (variant.stockQuantity > 0)
          StockMovementDraft(
            productId: product.id,
            variantId: variant.id,
            delta: variant.stockQuantity,
            type: StockMovementType.initial,
          ),
    ];
    if (initial.isEmpty) return created;

    final Result<List<StockMovement>> recorded = await _inventoryRepository
        .recordMovements(initial);
    if (recorded case Failed<List<StockMovement>>(:final Failure failure)) {
      return Failed<Product>(failure);
    }
    return _productRepository.getProductById(product.id);
  }
}

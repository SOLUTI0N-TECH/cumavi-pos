import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/in_memory_product_data_source.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_draft.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/create_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/find_product_by_code.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/get_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/get_products.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/datasources/in_memory_inventory_data_source.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/usecases/stock_usecases.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/cubit/adjust_stock_cubit.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/cubit/receive_stock_cubit.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/cubit/stock_movements_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_draft.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/register_sale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The stock ledger over the in-memory catalog, without latency.
void main() {
  late ProductRepository products;
  late InventoryRepository inventory;

  setUp(() {
    final InMemoryProductDataSource catalog = InMemoryProductDataSource(
      latency: Duration.zero,
    );
    products = ProductRepositoryImpl(catalog);
    inventory = InventoryRepositoryImpl(
      dataSource: InMemoryInventoryDataSource(
        products: catalog,
        latency: Duration.zero,
      ),
      sessionRepository: InMemorySessionStore(),
    );
  });

  Future<Product> product(String id) async =>
      (await products.getProductById(id)).valueOrNull!;

  Future<List<StockMovement>> movementsOf(String productId) async =>
      (await inventory.getMovements(StockMovementQuery(productId: productId)))
          .valueOrNull!;

  AdjustStock adjustStock() =>
      AdjustStock(inventoryRepository: inventory, productRepository: products);

  test('the seeded history ends at every current stock', () async {
    for (final Product seeded in CatalogSeedData.products()) {
      final List<StockMovement> history = await movementsOf(seeded.id);
      final List<ProductVariant?> targets = seeded.hasVariants
          ? seeded.variants
          : <ProductVariant?>[null];
      for (final ProductVariant? variant in targets) {
        final int stock = variant?.stockQuantity ?? seeded.stockQuantity;
        final StockMovement? latest = history
            .where((StockMovement m) => m.variantId == variant?.id)
            .firstOrNull;
        expect(latest?.stockAfter ?? 0, stock, reason: '${seeded.id} $variant');
      }
    }
  });

  group('ReceiveStock', () {
    test('adds the units with their cost and supplier', () async {
      final List<StockMovement> recorded = (await ReceiveStock(inventory)(
        const GoodsReceipt(
          note: ' Importadora Andina ',
          lines: <ReceivingLine>[
            ReceivingLine(productId: 'p-008', quantity: 5, unitCost: 27.5),
            ReceivingLine(productId: 'p-011', variantId: 'gris/l', quantity: 3),
          ],
        ),
      )).valueOrNull!;

      expect(recorded.map((StockMovement m) => m.stockAfter), <int>[23, 7]);
      expect(recorded.first.type, StockMovementType.purchase);
      expect(recorded.first.unitCost, 27.5);
      expect(
        recorded.every((StockMovement m) => m.note == 'Importadora Andina'),
        isTrue,
      );
      expect(recorded.last.variantLabel, 'Gris · L');
      expect((await product('p-008')).stockQuantity, 23);
    });

    test('refuses an empty receipt or zero units', () async {
      expect(
        (await ReceiveStock(inventory)(
          const GoodsReceipt(lines: <ReceivingLine>[]),
        )).failureOrNull?.code,
        FailureCode.emptyGoodsReceipt,
      );
      expect(
        (await ReceiveStock(inventory)(
          const GoodsReceipt(
            lines: <ReceivingLine>[
              ReceivingLine(productId: 'p-008', quantity: 0),
            ],
          ),
        )).failureOrNull?.code,
        FailureCode.invalidStockQuantity,
      );
    });
  });

  group('AdjustStock', () {
    test('a count records the difference', () async {
      final StockMovement movement = (await adjustStock()(
        const StockAdjustment(
          productId: 'p-008',
          mode: AdjustmentMode.count,
          quantity: 15,
          reason: AdjustmentReason.count,
        ),
      )).valueOrNull!;

      expect(movement.delta, -3);
      expect(movement.stockAfter, 15);
      expect(movement.reason, AdjustmentReason.count);
      expect((await product('p-008')).stockQuantity, 15);
    });

    test('a count equal to the stock changes nothing', () async {
      final Failure? failure = (await adjustStock()(
        const StockAdjustment(
          productId: 'p-008',
          mode: AdjustmentMode.count,
          quantity: 18,
          reason: AdjustmentReason.count,
        ),
      )).failureOrNull;

      expect(failure?.code, FailureCode.noStockChange);
    });

    test('never leaves the stock below zero', () async {
      final Failure? failure = (await adjustStock()(
        const StockAdjustment(
          productId: 'p-014',
          mode: AdjustmentMode.remove,
          quantity: 2,
          reason: AdjustmentReason.loss,
        ),
      )).failureOrNull;

      expect(failure?.code, FailureCode.insufficientStock);
      expect((await product('p-014')).stockQuantity, 1);
    });

    test('needs a reason', () async {
      final Failure? failure = (await adjustStock()(
        const StockAdjustment(
          productId: 'p-008',
          mode: AdjustmentMode.add,
          quantity: 1,
          reason: null,
        ),
      )).failureOrNull;

      expect(failure?.code, FailureCode.adjustmentReasonRequired);
    });
  });

  test('a batch with one impossible change records nothing', () async {
    final int before = (await movementsOf('p-008')).length;

    final Result<List<StockMovement>> result = await inventory.recordMovements(
      const <StockMovementDraft>[
        StockMovementDraft(
          productId: 'p-008',
          delta: 4,
          type: StockMovementType.purchase,
        ),
        StockMovementDraft(
          productId: 'p-014',
          delta: -5,
          type: StockMovementType.adjustment,
          reason: AdjustmentReason.loss,
        ),
      ],
    );

    expect(result.failureOrNull?.code, FailureCode.insufficientStock);
    expect((await product('p-008')).stockQuantity, 18);
    expect(await movementsOf('p-008'), hasLength(before));
  });

  test('a new product enters with an "Inventario inicial"', () async {
    final Product created =
        (await CreateProduct(
              productRepository: products,
              inventoryRepository: inventory,
            )(
              ProductDraft(
                name: 'Taza de cerámica',
                categoryId: CatalogSeedData.accessories.id,
                salePrice: 35,
                costPrice: 15,
                stockQuantity: 6,
              ),
            ))
            .valueOrNull!;

    expect(created.stockQuantity, 6);
    final StockMovement initial = (await movementsOf(created.id)).single;
    expect(initial.type, StockMovementType.initial);
    expect(initial.delta, 6);
    expect(initial.userName, 'Carla Mamani');
  });

  test('queries filter by type and keep the newest', () async {
    final List<StockMovement> purchases = (await inventory.getMovements(
      const StockMovementQuery(
        types: <StockMovementType>{StockMovementType.purchase},
      ),
    )).valueOrNull!;
    final List<StockMovement> latest = (await inventory.getMovements(
      const StockMovementQuery(limit: 3),
    )).valueOrNull!;

    expect(purchases.map((StockMovement m) => m.productId), <String>[
      'p-011',
      'p-008',
    ]);
    expect(latest, hasLength(3));
    expect(latest.first.type, StockMovementType.adjustment);
  });

  test('a sale takes its units out as movements tied to it', () async {
    await GetIt.instance.reset();
    configureDependencies(deviceServices: DeviceServices.demo);
    final Product cap = (await injector<ProductRepository>().getProductById(
      'p-008',
    )).valueOrNull!;

    final Sale sale = (await injector<RegisterSale>()(
      SaleDraft(
        cart: const Cart.empty().addProduct(cap, quantity: 2),
        paymentMethod: PaymentMethod.qr,
        amountReceived: 130,
      ),
    )).valueOrNull!;

    final StockMovement movement =
        (await injector<InventoryRepository>().getMovements(
          const StockMovementQuery(productId: 'p-008', limit: 1),
        )).valueOrNull!.single;
    expect(movement.type, StockMovementType.sale);
    expect(movement.saleId, sale.id);
    expect(movement.delta, -2);
    expect(movement.stockAfter, 16);
  });

  group('cubits', () {
    test('AdjustStockCubit previews and saves a count', () async {
      final AdjustStockCubit cubit = AdjustStockCubit(
        getProduct: GetProduct(products),
        adjustStock: adjustStock(),
        productId: 'p-011',
      );
      await cubit.load();
      expect(cubit.state.variant?.label, 'Negra · S');

      cubit
        ..variantSelected('negra/m')
        ..quantityChanged(4);
      expect(cubit.state.currentStock, 6);
      expect(cubit.state.delta, -2);
      expect(cubit.state.canSubmit, isTrue);

      // Removing asks for a new reason.
      cubit.modeSelected(AdjustmentMode.remove);
      expect(cubit.state.reason, isNull);
      expect(cubit.state.canSubmit, isFalse);

      cubit
        ..modeSelected(AdjustmentMode.count)
        ..quantityChanged(4);
      await cubit.submit();
      expect(cubit.state.status, AdjustStockStatus.saved);
      expect((await product('p-011')).variantById('negra/m')!.stockQuantity, 4);
      await cubit.close();
    });

    test('ReceiveStockCubit merges lines and adds by code', () async {
      final ReceiveStockCubit cubit = ReceiveStockCubit(
        getProducts: GetProducts(products),
        findProductByCode: FindProductByCode(products),
        receiveStock: ReceiveStock(inventory),
      );
      await cubit.load(productId: 'p-008');
      cubit.addLine(await product('p-008'));
      await cubit.addByCode(
        CatalogSeedData.barcodeFor('p-011', variantIndex: 2),
      );

      expect(cubit.state.lines.first.quantity, 2);
      expect(cubit.state.lines.last.variant?.label, 'Negra · M');
      expect(cubit.state.totalUnits, 3);

      await cubit.submit();
      expect(cubit.state.status, ReceiveStockStatus.saved);
      expect((await product('p-008')).stockQuantity, 20);
      await cubit.close();
    });

    test('StockMovementsCubit filters a product history', () async {
      final StockMovementsCubit cubit = StockMovementsCubit(
        getStockMovements: GetStockMovements(inventory),
        productId: 'p-008',
      );
      await cubit.load();
      expect(cubit.state.movements, hasLength(2));

      await cubit.filterSelected(MovementFilter.purchases);
      expect(cubit.state.movements.single.delta, 10);
      await cubit.close();
    });
  });
}

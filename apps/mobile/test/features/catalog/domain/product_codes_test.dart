import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/in_memory_product_data_source.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/services/demo_photo_capturer.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/services/mock_image_background_remover.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_code_match.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_draft.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/capture_product_photo.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/create_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/find_product_by_code.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/get_categories.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/get_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/manage_categories.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/product_code_rules.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/remove_photo_background.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/suggest_sku.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/update_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/product_form_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/product_form_state.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/datasources/in_memory_inventory_data_source.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// SKU and barcode rules, lookup by code and SKU suggestions, over the real
/// use cases and the in-memory catalog without latency.
void main() {
  late ProductRepository repository;
  late InventoryRepository inventory;

  setUp(() {
    final InMemoryProductDataSource products = InMemoryProductDataSource(
      latency: Duration.zero,
    );
    repository = ProductRepositoryImpl(products);
    inventory = InventoryRepositoryImpl(
      dataSource: InMemoryInventoryDataSource(
        products: products,
        latency: Duration.zero,
      ),
      sessionRepository: InMemorySessionStore(),
    );
  });

  ProductDraft draft({String? sku, String? barcode}) => ProductDraft(
    name: 'Gorra nueva',
    categoryId: CatalogSeedData.accessories.id,
    salePrice: 50,
    costPrice: 20,
    stockQuantity: 3,
    sku: sku,
    barcode: barcode,
  );

  final String cap = CatalogSeedData.barcodeFor('p-008');
  final String blackTeeM = CatalogSeedData.barcodeFor('p-011', variantIndex: 2);

  group('ProductCodeRules', () {
    test('stores codes trimmed, in capitals and without spaces', () {
      expect(ProductCodeRules.normalize(' cal 001 '), 'CAL001');
      expect(ProductCodeRules.normalizeOrNull('   '), isNull);
    });

    test('codes are optional but must be well formed', () {
      expect(ProductCodeRules.isValidSku(''), isTrue);
      expect(ProductCodeRules.isValidSku('cal-001'), isTrue);
      expect(ProductCodeRules.isValidSku('Ñandú'), isFalse);
      expect(ProductCodeRules.isValidBarcode(cap), isTrue);
      expect(ProductCodeRules.isValidBarcode('12'), isFalse);
    });

    test('a code cannot repeat inside the same product', () {
      final Failure? failure = ProductCodeRules.validate(
        draft(sku: 'ABC-1', barcode: 'abc-1'),
      );

      expect(failure?.code, FailureCode.productCodeRepeated);
      expect(failure?.detail, 'ABC-1');
    });
  });

  test('seeded barcodes are EAN-13 with their check digit', () {
    expect(cap, '7770000008001');
    expect(blackTeeM, hasLength(13));
  });

  group('FindProductByCode', () {
    test("a product's code finds it without a variant", () async {
      final ProductCodeMatch? match = (await FindProductByCode(repository)(cap))
          .valueOrNull;

      expect(match?.product.name, 'Gorra trucker blanca');
      expect(match?.variant, isNull);
    });

    test("a variant's code finds that exact variant", () async {
      final ProductCodeMatch? match = (await FindProductByCode(repository)(
        blackTeeM,
      )).valueOrNull;

      expect(match?.product.name, 'Polera básica');
      expect(match?.variant?.label, 'Negra · M');
    });

    test('typed SKUs ignore case and spaces', () async {
      final ProductCodeMatch? match = (await FindProductByCode(repository)(
        ' cal-001-roj-38 ',
      )).valueOrNull;

      expect(match?.variant?.label, 'Rojo · 38');
    });

    test('an unknown code says which one', () async {
      final Failure? failure = (await FindProductByCode(repository)('123456'))
          .failureOrNull;

      expect(failure?.code, FailureCode.productCodeNotFound);
      expect(failure?.detail, '123456');
    });
  });

  test('part of a barcode or SKU finds the product in search', () async {
    final List<String> byBarcode = (await repository.getProducts(
      query: cap.substring(0, 11),
    )).valueOrNull!.map((Product product) => product.name).toList();
    final List<String> bySku = (await repository.getProducts(query: 'acc-014'))
        .valueOrNull!
        .map((Product product) => product.name)
        .toList();

    expect(byBarcode, contains('Gorra trucker blanca'));
    expect(bySku, <String>['Billetera de cuero']);
  });

  group('codes are unique in the store', () {
    test('another product cannot take a code', () async {
      final Failure? failure = (await CreateProduct(
        productRepository: repository,
        inventoryRepository: inventory,
      )(draft(barcode: cap))).failureOrNull;

      expect(failure?.code, FailureCode.productCodeTaken);
      expect(failure?.detail, 'Gorra trucker blanca');
    });

    test('variant codes count too', () async {
      final Failure? failure = (await CreateProduct(
        productRepository: repository,
        inventoryRepository: inventory,
      )(draft(sku: 'rop-011-neg-m'))).failureOrNull;

      expect(failure?.code, FailureCode.productCodeTaken);
      expect(failure?.detail, 'Polera básica');
    });

    test('a product keeps its own codes when edited', () async {
      final Product stored = (await CreateProduct(
        productRepository: repository,
        inventoryRepository: inventory,
      )(draft(sku: 'gor-1', barcode: '5550001'))).valueOrNull!;
      expect(stored.sku, 'GOR-1');

      final Result<Product> updated = await UpdateProduct(repository)(
        ProductUpdate(
          productId: stored.id,
          draft: draft(sku: 'GOR-1', barcode: '5550001'),
        ),
      );

      expect(updated.failureOrNull, isNull);
    });
  });

  group('SuggestSku', () {
    test('continues the numbering of the category', () async {
      expect((await SuggestSku(repository)('Calzado')).valueOrNull, 'CAL-013');
      expect((await SuggestSku(repository)('Hogar')).valueOrNull, 'HOG-001');
      expect((await SuggestSku(repository)('TV')).valueOrNull, 'PRD-001');
    });

    test('variant SKUs add three letters of each value', () {
      expect(
        SuggestSku.variantSku(
          'CAL-013',
          ProductVariant.fromValues(
            optionValues: const <String, String>{
              'Color': 'Azul marino',
              'Talla': '40',
            },
            stockQuantity: 0,
          ),
        ),
        'CAL-013-AZU-40',
      );
    });
  });

  group('product form codes', () {
    ProductFormCubit buildCubit() => ProductFormCubit(
      getCategories: GetCategories(repository),
      createCategory: CreateCategory(repository),
      getProduct: GetProduct(repository),
      createProduct: CreateProduct(
        productRepository: repository,
        inventoryRepository: inventory,
      ),
      updateProduct: UpdateProduct(repository),
      captureProductPhoto: const CaptureProductPhoto(DemoPhotoCapturer()),
      removePhotoBackground: const RemovePhotoBackground(
        MockImageBackgroundRemover(latency: Duration.zero),
      ),
      suggestSku: SuggestSku(repository),
    );

    test('generating a SKU also codes the variants without one', () async {
      final ProductFormCubit cubit = buildCubit();
      await cubit.load();
      cubit
        ..addOption('Talla')
        ..addOptionValue(0, 'S')
        ..addOptionValue(0, 'M')
        ..variantCodesChanged('m', sku: 'mine-m', barcode: '');

      expect(await cubit.generateSku(), 'ROP-014');
      expect(
        cubit.state.variants.map((ProductVariant variant) => variant.sku),
        <String>['ROP-014-S', 'MINE-M'],
      );
      await cubit.close();
    });

    test('a scanned barcode starts a new product', () async {
      final ProductFormCubit cubit = buildCubit();
      await cubit.load(barcode: '7770000099001');
      cubit
        ..nameChanged('Taza')
        ..salePriceChanged(30)
        ..costPriceChanged(10);

      await cubit.submit();

      expect(cubit.state.status, ProductFormStatus.saved);
      expect(cubit.state.savedProduct?.barcode, '7770000099001');
      await cubit.close();
    });

    test('an invalid code blocks saving', () async {
      final ProductFormCubit cubit = buildCubit();
      await cubit.load();
      cubit
        ..nameChanged('Taza')
        ..salePriceChanged(30)
        ..costPriceChanged(10)
        ..skuChanged('Ñ');

      expect(cubit.state.canSubmit, isFalse);
      await cubit.close();
    });
  });
}

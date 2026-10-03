import 'package:bloc_test/bloc_test.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/in_memory_product_data_source.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/services/demo_photo_capturer.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/services/mock_image_background_remover.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/services/photo_capturer.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/capture_product_photo.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/create_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/get_categories.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/get_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/manage_categories.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/remove_photo_background.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/suggest_sku.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/update_product.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/product_form_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/product_form_state.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/datasources/in_memory_inventory_data_source.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Variant logic of the product form, over the real use cases and the
/// in-memory catalog without latency.
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

  ProductVariant variant(ProductFormCubit cubit, String id) =>
      cubit.state.variants.singleWhere((ProductVariant v) => v.id == id);

  List<String> labels(ProductFormCubit cubit) => cubit.state.variants
      .map((ProductVariant variant) => variant.label)
      .toList();

  test(
    'regenerates one variant per combination as types and values change',
    () {
      final ProductFormCubit cubit = buildCubit()
        ..addOption('Color')
        ..addOptionValue(0, 'Rojo')
        ..addOptionValue(0, 'Azul')
        ..addOption('Talla')
        ..addOptionValue(1, 'S')
        ..addOptionValue(1, 'M');
      addTearDown(cubit.close);
      expect(labels(cubit), <String>[
        'Rojo · S',
        'Rojo · M',
        'Azul · S',
        'Azul · M',
      ]);
      expect(cubit.state.hasIncompleteOptions, isFalse);

      cubit.removeOptionValue(0, 'Azul');
      expect(labels(cubit), <String>['Rojo · S', 'Rojo · M']);

      cubit.removeOption(0);
      expect(labels(cubit), <String>['S', 'M']);
    },
  );

  test('a type without values keeps the form from being saved', () {
    final ProductFormCubit cubit = buildCubit()
      ..nameChanged('Polera básica')
      ..categorySelected('clothing')
      ..salePriceChanged(89)
      ..costPriceChanged(45)
      ..addOption('Talla');
    addTearDown(cubit.close);
    expect(cubit.state.hasIncompleteOptions, isTrue);
    expect(cubit.state.canSubmit, isFalse);

    cubit.addOptionValue(0, 'M');
    expect(cubit.state.canSubmit, isTrue);
  });

  blocTest<ProductFormCubit, ProductFormState>(
    'keeps the stock of the existing variants when a value is added',
    build: buildCubit,
    act: (ProductFormCubit cubit) => cubit
      ..addOption('Talla')
      ..addOptionValue(0, 'S')
      ..addOptionValue(0, 'M')
      ..incrementVariantStock('s')
      ..incrementVariantStock('s')
      ..incrementVariantStock('m')
      ..addOptionValue(0, 'L'),
    verify: (ProductFormCubit cubit) {
      expect(variant(cubit, 's').stockQuantity, 2);
      expect(variant(cubit, 'm').stockQuantity, 1);
      expect(variant(cubit, 'l').stockQuantity, 0);
      expect(cubit.state.totalStock, 3);
    },
  );

  blocTest<ProductFormCubit, ProductFormState>(
    'new sizes inherit the photo of their color when a second type is added',
    build: buildCubit,
    act: (ProductFormCubit cubit) async {
      await cubit.addImage(PhotoSource.gallery);
      cubit
        ..addOption('Color')
        ..addOptionValue(0, 'Rojo')
        ..addOptionValue(0, 'Azul')
        ..variantImageSelected('rojo', cubit.state.extraImages.single.id)
        ..addOption('Talla')
        ..addOptionValue(1, 'S')
        ..addOptionValue(1, 'M');
    },
    verify: (ProductFormCubit cubit) {
      final String redPhoto = cubit.state.extraImages.single.id;
      expect(variant(cubit, 'rojo/s').imageId, redPhoto);
      expect(variant(cubit, 'rojo/m').imageId, redPhoto);
      expect(variant(cubit, 'azul/s').imageId, isNull);
      expect(variant(cubit, 'azul/m').imageId, isNull);
    },
  );

  blocTest<ProductFormCubit, ProductFormState>(
    'a new size keeps the photo of its color; a new color starts without one',
    build: buildCubit,
    act: (ProductFormCubit cubit) async {
      await cubit.load(productId: 'p-001');
      cubit
        ..addOptionValue(1, '43')
        ..addOptionValue(0, 'Verde');
    },
    verify: (ProductFormCubit cubit) {
      expect(cubit.state.variants, hasLength(4 * 6));
      expect(variant(cubit, 'rojo/43').imageId, 'p-001-img-1');
      expect(variant(cubit, 'azul/43').imageId, 'p-001-img-2');
      expect(variant(cubit, 'verde/40').imageId, isNull);
      // The existing ones keep their stock.
      expect(variant(cubit, 'rojo/40').stockQuantity, 3);
    },
  );

  blocTest<ProductFormCubit, ProductFormState>(
    'a photo chosen with a shared option goes to every variant of that value',
    build: buildCubit,
    act: (ProductFormCubit cubit) async {
      await cubit.addImage(PhotoSource.gallery);
      cubit
        ..addOption('Color')
        ..addOptionValue(0, 'Rojo')
        ..addOptionValue(0, 'Azul')
        ..addOption('Talla')
        ..addOptionValue(1, 'S')
        ..addOptionValue(1, 'M')
        ..variantImageSelected(
          'azul/m',
          cubit.state.extraImages.single.id,
          sharedOption: 'Color',
        );
    },
    verify: (ProductFormCubit cubit) {
      final String bluePhoto = cubit.state.extraImages.single.id;
      expect(variant(cubit, 'azul/s').imageId, bluePhoto);
      expect(variant(cubit, 'azul/m').imageId, bluePhoto);
      expect(variant(cubit, 'rojo/s').imageId, isNull);
    },
  );

  blocTest<ProductFormCubit, ProductFormState>(
    'removing a photo sends its variants back to the main one',
    build: buildCubit,
    act: (ProductFormCubit cubit) async {
      await cubit.addImage(PhotoSource.gallery);
      final String imageId = cubit.state.extraImages.single.id;
      cubit
        ..addOption('Color')
        ..addOptionValue(0, 'Rojo')
        ..addOptionValue(0, 'Azul')
        ..variantImageSelected('rojo', imageId)
        ..removeImage(imageId);
    },
    verify: (ProductFormCubit cubit) {
      expect(cubit.state.extraImages, isEmpty);
      expect(
        cubit.state.variants.map((ProductVariant variant) => variant.imageId),
        everyElement(isNull),
      );
    },
  );

  blocTest<ProductFormCubit, ProductFormState>(
    'renaming a type keeps the stock and photos of its variants',
    build: buildCubit,
    act: (ProductFormCubit cubit) => cubit
      ..addOption('Tamaño')
      ..addOptionValue(0, 'S')
      ..incrementVariantStock('s')
      ..renameOption(0, 'Talla'),
    verify: (ProductFormCubit cubit) {
      expect(cubit.state.options.single.name, 'Talla');
      expect(variant(cubit, 's').optionValues, <String, String>{'Talla': 'S'});
      expect(variant(cubit, 's').stockQuantity, 1);
    },
  );

  blocTest<ProductFormCubit, ProductFormState>(
    'edit mode prefills the product and saves it without touching stock',
    build: buildCubit,
    act: (ProductFormCubit cubit) async {
      await cubit.load(productId: 'p-001');
      cubit
        ..nameChanged('Zapatillas urbanas 2026')
        ..incrementVariantStock('negro/42');
      await cubit.submit();
    },
    verify: (ProductFormCubit cubit) async {
      expect(cubit.state.isEditing, isTrue);
      expect(cubit.state.status, ProductFormStatus.saved);
      expect(cubit.state.savedProduct!.id, 'p-001');

      // Stored in place: no new product was created.
      final Result<List<Product>> products = await repository.getProducts();
      final List<Product> all = (products as Success<List<Product>>).value;
      expect(all, hasLength(CatalogSeedData.products().length));
      final Product stored = all.singleWhere(
        (Product product) => product.id == 'p-001',
      );
      expect(stored.name, 'Zapatillas urbanas 2026');
      expect(stored.variants, hasLength(15));
      // Stock is read-only while editing; it changes through movements.
      expect(
        cubit.state.variants
            .firstWhere((ProductVariant v) => v.id == 'negro/42')
            .stockQuantity,
        0,
      );
      expect(stored.variantById('negro/42')!.stockQuantity, 0);
      // The color photos are kept.
      expect(stored.variantById('azul/40')!.imageId, 'p-001-img-2');
    },
  );

  blocTest<ProductFormCubit, ProductFormState>(
    'creating after editing starts from a blank form',
    build: buildCubit,
    act: (ProductFormCubit cubit) async {
      await cubit.load(productId: 'p-001');
      await cubit.load();
    },
    verify: (ProductFormCubit cubit) {
      expect(cubit.state.isEditing, isFalse);
      expect(cubit.state.productId, isNull);
      expect(cubit.state.name, isEmpty);
      expect(cubit.state.options, isEmpty);
      expect(cubit.state.variants, isEmpty);
      expect(cubit.state.categories, isNotEmpty);
    },
  );
}

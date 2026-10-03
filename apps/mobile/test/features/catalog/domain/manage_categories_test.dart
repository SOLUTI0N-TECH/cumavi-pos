import 'package:bloc_test/bloc_test.dart';
import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/usecases/use_case.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/core/utils/text_normalizer.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/entities/business_profile.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/entities/sales_setup.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/usecases/save_sales_setup.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/in_memory_product_data_source.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_category.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/manage_categories.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Category management over the real use cases and the in-memory catalog
/// without latency.
void main() {
  late ProductRepository repository;

  setUp(() {
    repository = ProductRepositoryImpl(
      InMemoryProductDataSource(latency: Duration.zero),
    );
  });

  Future<List<String>> categoryNames({bool includeArchived = false}) async =>
      (await repository.getCategories(includeArchived: includeArchived))
          .valueOrNull!
          .map((ProductCategory category) => category.name)
          .toList();

  Future<ProductCategory> categoryNamed(String name) async =>
      (await repository.getCategories(includeArchived: true)).valueOrNull!
          .singleWhere((ProductCategory category) => category.name == name);

  test('TextNormalizer ignores case, accents and extra spaces', () {
    expect(
      TextNormalizer.normalize('  Artículos   de Baño '),
      'articulos de bano',
    );
  });

  group('CreateCategory', () {
    test('adds the category at the end of the order', () async {
      final Result<ProductCategory> result = await CreateCategory(repository)(
        '  Hogar ',
      );

      expect(result.valueOrNull?.name, 'Hogar');
      expect(await categoryNames(), <String>[
        'Ropa',
        'Calzado',
        'Accesorios',
        'Hogar',
      ]);
    });

    test('rejects names too short or too long', () async {
      for (final String name in <String>['A', 'x' * 31]) {
        final Result<ProductCategory> result = await CreateCategory(repository)(
          name,
        );

        expect(result.failureOrNull?.code, FailureCode.categoryNameInvalid);
      }
    });

    test('rejects a taken name, ignoring case, accents and archived', () async {
      final ProductCategory shoes = await categoryNamed('Calzado');
      await SetCategoryArchived(repository)(
        CategoryArchiving(categoryId: shoes.id, archived: true),
      );

      for (final String name in <String>['ROPA', 'calzado', 'Accésorios']) {
        final Result<ProductCategory> result = await CreateCategory(repository)(
          name,
        );

        expect(result.failureOrNull?.code, FailureCode.categoryNameTaken);
      }
    });
  });

  test('renaming shows the new name on its products', () async {
    final ProductCategory clothing = await categoryNamed('Ropa');

    final Result<ProductCategory> result = await RenameCategory(repository)(
      CategoryRename(categoryId: clothing.id, name: 'Prendas'),
    );

    expect(result.valueOrNull?.name, 'Prendas');
    final List<Product> products = (await repository.getProducts()).valueOrNull!
        .where((Product product) => product.category.id == clothing.id)
        .toList();
    expect(products, isNotEmpty);
    expect(
      products.every((Product product) => product.category.name == 'Prendas'),
      isTrue,
    );
  });

  test('renaming to another category name fails', () async {
    final ProductCategory clothing = await categoryNamed('Ropa');

    final Result<ProductCategory> result = await RenameCategory(repository)(
      CategoryRename(categoryId: clothing.id, name: 'calzado'),
    );

    expect(result.failureOrNull?.code, FailureCode.categoryNameTaken);
  });

  test('reorder saves the order the seller chose', () async {
    final List<ProductCategory> categories =
        (await repository.getCategories()).valueOrNull!;

    await ReorderCategories(repository)(<String>[
      for (final ProductCategory category in categories.reversed) category.id,
    ]);

    expect(await categoryNames(), <String>['Accesorios', 'Calzado', 'Ropa']);
  });

  test('archived categories leave pickers but their products stay', () async {
    final ProductCategory shoes = await categoryNamed('Calzado');
    final int productsBefore =
        (await repository.getProducts()).valueOrNull!.length;

    await SetCategoryArchived(repository)(
      CategoryArchiving(categoryId: shoes.id, archived: true),
    );

    expect(await categoryNames(), <String>['Ropa', 'Accesorios']);
    expect(await categoryNames(includeArchived: true), contains('Calzado'));
    expect(
      (await repository.getProducts()).valueOrNull!.length,
      productsBefore,
    );

    await SetCategoryArchived(repository)(
      CategoryArchiving(categoryId: shoes.id, archived: false),
    );
    expect(await categoryNames(), contains('Calzado'));
  });

  test('overview counts the products of each category', () async {
    final List<CategoryOverview> overview = (await GetCategoryOverview(
      repository,
    )(const NoParams())).valueOrNull!;
    final List<Product> products =
        (await repository.getProducts()).valueOrNull!;

    for (final CategoryOverview item in overview) {
      expect(
        item.productCount,
        products
            .where((Product product) => product.category.id == item.category.id)
            .length,
      );
    }
  });

  test('SaveSalesSetup creates only the categories that are missing', () async {
    final SaveSalesSetup saveSalesSetup = SaveSalesSetup(
      authRepository: MockAuthRepository(
        sessionRepository: InMemorySessionStore(),
        latency: Duration.zero,
      ),
      productRepository: repository,
    );

    final Result<BusinessProfile> result = await saveSalesSetup(
      const SalesSetup(
        categoryNames: <String>['ropa', 'Electrónica', 'Hogar'],
        acceptedPaymentMethods: <PaymentMethod>{PaymentMethod.cash},
      ),
    );

    expect(result.failureOrNull, isNull);
    expect(await categoryNames(), <String>[
      'Ropa',
      'Calzado',
      'Accesorios',
      'Electrónica',
      'Hogar',
    ]);
  });

  group('CategoriesCubit', () {
    CategoriesCubit buildCubit() => CategoriesCubit(
      getCategoryOverview: GetCategoryOverview(repository),
      createCategory: CreateCategory(repository),
      renameCategory: RenameCategory(repository),
      reorderCategories: ReorderCategories(repository),
      setCategoryArchived: SetCategoryArchived(repository),
    );

    List<String> names(Iterable<CategoryOverview> items) =>
        items.map((CategoryOverview item) => item.category.name).toList();

    test('moves a category and keeps the new order', () async {
      final CategoriesCubit cubit = buildCubit();
      await cubit.load();

      await cubit.reorder(2, 0);

      expect(names(cubit.state.active), <String>[
        'Accesorios',
        'Ropa',
        'Calzado',
      ]);
      expect(await categoryNames(), <String>['Accesorios', 'Ropa', 'Calzado']);
      await cubit.close();
    });

    test('archive moves the category to the archived section', () async {
      final CategoriesCubit cubit = buildCubit();
      await cubit.load();
      final CategoryOverview shoes = cubit.state.active[1];

      final Failure? failure = await cubit.setArchived(
        shoes.category.id,
        archived: true,
      );

      expect(failure, isNull);
      expect(names(cubit.state.active), <String>['Ropa', 'Accesorios']);
      expect(names(cubit.state.archived), <String>['Calzado']);
      await cubit.close();
    });

    blocTest<CategoriesCubit, CategoriesState>(
      'create returns the failure and leaves the list as is',
      build: buildCubit,
      act: (CategoriesCubit cubit) async {
        await cubit.load();
        expect(
          (await cubit.create('Ropa'))?.code,
          FailureCode.categoryNameTaken,
        );
      },
      verify: (CategoriesCubit cubit) {
        expect(cubit.state.items, hasLength(3));
      },
    );
  });
}

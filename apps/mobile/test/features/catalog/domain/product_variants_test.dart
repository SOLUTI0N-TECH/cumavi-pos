import 'package:cumavi_pos_mobile/core/error/exceptions.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/in_memory_product_data_source.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_draft.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_image.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/product_draft_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const List<VariantOption> _colorAndSize = <VariantOption>[
  VariantOption(name: 'Color', values: <String>['Rojo', 'Azul']),
  VariantOption(name: 'Talla', values: <String>['S', 'M', 'L']),
];

const List<ProductImage> _images = <ProductImage>[
  ProductImage(id: 'img-1', path: 'assets/images/products/sneakers_red.jpg'),
  ProductImage(id: 'img-2', path: 'assets/images/products/sneakers_blue.jpg'),
];

ProductDraft _draft({
  List<VariantOption> options = _colorAndSize,
  List<ProductVariant>? variants,
}) {
  return ProductDraft(
    name: 'Polera básica',
    categoryId: 'clothing',
    salePrice: 75,
    costPrice: 38,
    images: _images,
    options: options,
    variants:
        variants ??
        <ProductVariant>[
          for (final Map<String, String> values in combinationsOf(options))
            ProductVariant.fromValues(
              optionValues: values,
              stockQuantity: 2,
              imageId: values['Color'] == 'Azul' ? 'img-2' : 'img-1',
            ),
        ],
  );
}

void main() {
  group('combinationsOf', () {
    test('crosses every value of every option, in option order', () {
      final List<String> labels = combinationsOf(_colorAndSize)
          .map((Map<String, String> values) => values.values.join(' · '))
          .toList();

      expect(labels, <String>[
        'Rojo · S',
        'Rojo · M',
        'Rojo · L',
        'Azul · S',
        'Azul · M',
        'Azul · L',
      ]);
    });

    test('skips options that have no values yet', () {
      expect(
        combinationsOf(const <VariantOption>[
          VariantOption(name: 'Talla', values: <String>['S']),
          VariantOption(name: 'Color', values: <String>[]),
        ]),
        <Map<String, String>>[
          <String, String>{'Talla': 'S'},
        ],
      );
    });
  });

  group('ProductDraftRules', () {
    test('accepts a product with complete variants', () {
      expect(ProductDraftRules.validate(_draft()), isNull);
    });

    test('rejects a variant type without values', () {
      final ProductDraft draft = _draft(
        options: const <VariantOption>[
          VariantOption(name: 'Color', values: <String>['Rojo']),
          VariantOption(name: 'Talla', values: <String>[]),
        ],
      );

      expect(
        ProductDraftRules.validate(draft)?.code,
        FailureCode.incompleteVariantOptions,
      );
    });

    test('rejects repeated values', () {
      final ProductDraft draft = _draft(
        options: const <VariantOption>[
          VariantOption(name: 'Talla', values: <String>['M', 'm']),
        ],
      );

      expect(
        ProductDraftRules.validate(draft)?.code,
        FailureCode.incompleteVariantOptions,
      );
    });

    test('rejects a variant pointing to a photo that is not uploaded', () {
      final ProductDraft draft = _draft(
        variants: <ProductVariant>[
          ProductVariant.fromValues(
            optionValues: const <String, String>{'Color': 'Rojo', 'Talla': 'S'},
            stockQuantity: 1,
            imageId: 'img-99',
          ),
        ],
      );

      expect(
        ProductDraftRules.validate(draft)?.code,
        FailureCode.incompleteVariantOptions,
      );
    });

    test('rejects negative stock in a variant', () {
      final ProductDraft draft = _draft(
        variants: <ProductVariant>[
          ProductVariant.fromValues(
            optionValues: const <String, String>{'Color': 'Rojo', 'Talla': 'S'},
            stockQuantity: -1,
          ),
        ],
      );

      expect(
        ProductDraftRules.validate(draft)?.code,
        FailureCode.negativeStock,
      );
    });
  });

  group('InMemoryProductDataSource with variants', () {
    late InMemoryProductDataSource dataSource;

    setUp(() {
      dataSource = InMemoryProductDataSource(latency: Duration.zero);
    });

    Future<Product> sneakers() async => (await dataSource.fetchProducts())
        .firstWhere((Product product) => product.id == 'p-001');

    test('the product stock is the sum of its variants', () async {
      final Product product = await sneakers();

      expect(product.hasVariants, isTrue);
      expect(product.stockQuantity, 12);
      expect(product.variants, hasLength(15));
    });

    test('a sale reduces only the sold variant', () async {
      final Product before = await sneakers();
      final ProductVariant red40 = before.variantById('rojo/40')!;

      await dataSource.applyStockMovements(<StockMovement>[
        StockMovement(productId: 'p-001', variantId: red40.id, quantity: 2),
      ]);

      final Product after = await sneakers();
      expect(after.variantById('rojo/40')!.stockQuantity, 1);
      expect(after.variantById('rojo/39')!.stockQuantity, 2);
      expect(after.stockQuantity, before.stockQuantity - 2);
    });

    test('a movement without stock changes nothing', () async {
      final Product before = await sneakers();

      await expectLater(
        dataSource.applyStockMovements(const <StockMovement>[
          StockMovement(productId: 'p-001', variantId: 'rojo/40', quantity: 1),
          StockMovement(productId: 'p-001', variantId: 'negro/38', quantity: 1),
        ]),
        throwsA(
          isA<DataSourceException>().having(
            (DataSourceException exception) => exception.code,
            'code',
            FailureCode.insufficientStock,
          ),
        ),
      );
      expect(await sneakers(), before);
    });

    test('editing keeps the id and creation date', () async {
      final Product before = await sneakers();

      final Product updated = await dataSource.updateProduct('p-001', _draft());

      expect(updated.id, 'p-001');
      expect(updated.createdAt, before.createdAt);
      expect(updated.name, 'Polera básica');
      expect(updated.variants, hasLength(6));
      expect(updated.stockQuantity, 12);
    });
  });
}

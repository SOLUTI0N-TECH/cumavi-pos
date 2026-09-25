import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_category.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_image.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart_line.dart';
import 'package:flutter_test/flutter_test.dart';

Product buildProduct({
  String id = 'p-1',
  double salePrice = 100,
  int stockQuantity = 3,
  List<ProductVariant> variants = const <ProductVariant>[],
}) {
  return Product(
    id: id,
    name: 'Producto $id',
    category: const ProductCategory(id: 'c-1', name: 'Ropa'),
    salePrice: salePrice,
    costPrice: salePrice / 2,
    stockQuantity: stockQuantity,
    images: const <ProductImage>[
      ProductImage(
        id: 'img-1',
        path: 'assets/images/products/tshirt_black.jpg',
      ),
      ProductImage(id: 'img-2', path: 'assets/images/products/tshirt_gray.jpg'),
    ],
    createdAt: DateTime(2026, 9, 17),
    options: variants.isEmpty
        ? const <VariantOption>[]
        : const <VariantOption>[
            VariantOption(name: 'Color', values: <String>['Negra', 'Gris']),
            VariantOption(name: 'Talla', values: <String>['M']),
          ],
    variants: variants,
  );
}

final ProductVariant blackM = ProductVariant.fromValues(
  optionValues: const <String, String>{'Color': 'Negra', 'Talla': 'M'},
  stockQuantity: 2,
  imageId: 'img-1',
);

final ProductVariant grayM = ProductVariant.fromValues(
  optionValues: const <String, String>{'Color': 'Gris', 'Talla': 'M'},
  stockQuantity: 1,
  imageId: 'img-2',
);

void main() {
  group('Cart', () {
    test('starts empty', () {
      const Cart cart = Cart.empty();

      expect(cart.isEmpty, isTrue);
      expect(cart.itemCount, 0);
      expect(cart.total, 0);
    });

    test('adds a product and adds up its line', () {
      final Cart cart = const Cart.empty().addProduct(buildProduct());

      expect(cart.lines, hasLength(1));
      expect(cart.itemCount, 1);
      expect(cart.subtotal, 100);
    });

    test('groups units of the same product in one line', () {
      final Product product = buildProduct();
      final Cart cart = const Cart.empty()
          .addProduct(product)
          .addProduct(product);

      expect(cart.lines, hasLength(1));
      expect(cart.quantityOf(product.id), 2);
      expect(cart.total, 200);
    });

    test('never adds more units than the available stock', () {
      final Product product = buildProduct(stockQuantity: 2);
      final Cart cart = const Cart.empty()
          .addProduct(product)
          .addProduct(product)
          .addProduct(product);

      expect(cart.quantityOf(product.id), 2);
    });

    test('ignores products without stock', () {
      final Cart cart = const Cart.empty().addProduct(
        buildProduct(stockQuantity: 0),
      );

      expect(cart.isEmpty, isTrue);
    });

    test('decrementing the last unit removes the line', () {
      final Product product = buildProduct();
      final Cart cart = const Cart.empty()
          .addProduct(product)
          .decrementLine(product.id);

      expect(cart.isEmpty, isTrue);
    });

    test('a discount lowers the total but not the subtotal', () {
      final Cart cart = const Cart.empty()
          .addProduct(buildProduct())
          .applyDiscount(30);

      expect(cart.subtotal, 100);
      expect(cart.total, 70);
    });

    test('a discount never makes the total negative', () {
      final Cart cart = const Cart.empty()
          .addProduct(buildProduct())
          .applyDiscount(500);

      expect(cart.total, 0);
    });

    test('adds up lines of different products', () {
      final Cart cart = const Cart.empty()
          .addProduct(buildProduct(salePrice: 450))
          .addProduct(buildProduct(id: 'p-2', salePrice: 89))
          .addProduct(buildProduct(id: 'p-2', salePrice: 89));

      expect(cart.lines, hasLength(2));
      expect(cart.itemCount, 3);
      expect(cart.total, 628);
    });
  });

  group('Cart with variants', () {
    final Product tee = buildProduct(variants: <ProductVariant>[blackM, grayM]);

    test('needs a variant when the product has them', () {
      expect(const Cart.empty().addProduct(tee).isEmpty, isTrue);
    });

    test('keeps each variant in its own line', () {
      final Cart cart = const Cart.empty()
          .addProduct(tee, variant: blackM)
          .addProduct(tee, variant: grayM)
          .addProduct(tee, variant: blackM);

      expect(cart.lines, hasLength(2));
      expect(cart.quantityOf(tee.id), 3);
      expect(cart.quantityOfLine(CartLine.keyOf(tee.id, blackM.id)), 2);
    });

    test('limits each line to the stock of its variant', () {
      final Cart cart = const Cart.empty().addProduct(
        tee,
        variant: grayM,
        quantity: 5,
      );

      expect(cart.itemCount, 1);
      expect(cart.lines.single.canIncrement, isFalse);
    });

    test('shows the photo of the chosen variant', () {
      final Cart cart = const Cart.empty().addProduct(tee, variant: grayM);

      expect(
        cart.lines.single.imagePath,
        'assets/images/products/tshirt_gray.jpg',
      );
    });

    test('removes one variant without touching the other', () {
      final Cart cart = const Cart.empty()
          .addProduct(tee, variant: blackM)
          .addProduct(tee, variant: grayM)
          .removeLine(CartLine.keyOf(tee.id, blackM.id));

      expect(cart.lines.single.variant, grayM);
    });
  });
}

import 'package:cumavi_pos_mobile/core/constants/app_assets.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/view_data/variant_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Product sneakers;

  setUp(() {
    // Color Rojo/Azul/Negro × Talla 38–42, one photo per color.
    sneakers = CatalogSeedData.products().firstWhere(
      (Product product) => product.id == 'p-001',
    );
  });

  ProductVariant variantOf(Product product, String id) =>
      product.variantById(id)!;

  test('starts empty and shows the main photo', () {
    final VariantSelection selection = VariantSelection.initial(
      sneakers,
      const Cart.empty(),
    );

    expect(selection.values, isEmpty);
    expect(selection.isComplete, isFalse);
    expect(selection.missingOption?.name, 'Color');
    expect(selection.variant, isNull);
    expect(selection.canAdd, isFalse);
    expect(selection.imagePath, AppAssets.sneakersRed);
  });

  test('chooses the variant and shows its photo', () {
    final VariantSelection color = VariantSelection.initial(
      sneakers,
      const Cart.empty(),
    ).select('Color', 'Azul');

    expect(color.imagePath, AppAssets.sneakersBlue);
    expect(color.missingOption?.name, 'Talla');

    final VariantSelection complete = color.select('Talla', '40');
    expect(complete.variant?.id, 'azul/40');
    expect(complete.remaining, 2);
    expect(complete.canAdd, isTrue);
  });

  test('marks values without stock given the other choices', () {
    final VariantSelection selection = VariantSelection.initial(
      sneakers,
      const Cart.empty(),
    ).select('Color', 'Azul');

    expect(
      selection.availabilityOf('Talla', '40'),
      VariantValueAvailability.available,
    );
    // Rojo still has a 38.
    expect(
      selection.availabilityOf('Talla', '38'),
      VariantValueAvailability.unavailableWithSelection,
    );
    // No color has a 42.
    expect(
      selection.availabilityOf('Talla', '42'),
      VariantValueAvailability.soldOut,
    );
  });

  test('discounts the units already in the cart', () {
    final Cart cart = const Cart.empty().addProduct(
      sneakers,
      variant: variantOf(sneakers, 'azul/40'),
    );
    final VariantSelection selection = VariantSelection.initial(
      sneakers,
      cart,
    ).select('Color', 'Azul').select('Talla', '40');

    expect(selection.inCart, 1);
    expect(selection.remaining, 1);

    final Cart full = cart.addProduct(
      sneakers,
      variant: variantOf(sneakers, 'azul/40'),
    );
    final VariantSelection exhausted = VariantSelection.initial(
      sneakers,
      full,
    ).select('Color', 'Azul');
    expect(
      exhausted.availabilityOf('Talla', '40'),
      VariantValueAvailability.unavailableWithSelection,
    );
  });

  test('choosing a conflicting value drops the other choice', () {
    final VariantSelection selection = VariantSelection.initial(
      sneakers,
      const Cart.empty(),
    ).select('Color', 'Negro').select('Talla', '38');

    // Negro only comes in 40, so the color is dropped.
    expect(selection.values, <String, String>{'Talla': '38'});

    final VariantSelection kept = VariantSelection.initial(
      sneakers,
      const Cart.empty(),
    ).select('Talla', '40').select('Color', 'Negro');
    expect(kept.variant?.id, 'negro/40');
  });

  test('preselects the options with a single value', () {
    final Product product = sneakers.copyWith(
      options: const <VariantOption>[
        VariantOption(name: 'Color', values: <String>['Azul']),
        VariantOption(name: 'Talla', values: <String>['39', '40']),
      ],
      variants: <ProductVariant>[
        ProductVariant.fromValues(
          optionValues: const <String, String>{'Color': 'Azul', 'Talla': '39'},
          stockQuantity: 1,
        ),
        ProductVariant.fromValues(
          optionValues: const <String, String>{'Color': 'Azul', 'Talla': '40'},
          stockQuantity: 3,
        ),
      ],
    );

    final VariantSelection selection = VariantSelection.initial(
      product,
      const Cart.empty(),
    );

    expect(selection.values, <String, String>{'Color': 'Azul'});
    expect(selection.missingOption?.name, 'Talla');
  });
}

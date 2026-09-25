import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_variant.dart';

/// Demo catalog of a Bolivian clothing store, used while the app has no
/// backend. Prices are in bolivianos.
///
/// Most products vary by size and some by color too; each color has its own
/// photo so the variant picker shows the right one.
abstract final class CatalogSeedData {
  static const ProductCategory clothing = ProductCategory(
    id: 'clothing',
    name: 'Ropa',
  );
  static const ProductCategory footwear = ProductCategory(
    id: 'footwear',
    name: 'Calzado',
  );
  static const ProductCategory accessories = ProductCategory(
    id: 'accessories',
    name: 'Accesorios',
  );

  static const List<ProductCategory> categories = <ProductCategory>[
    clothing,
    footwear,
    accessories,
  ];

  static const List<String> _clothingSizes = <String>['S', 'M', 'L', 'XL'];

  static List<Product> products() {
    final DateTime now = DateTime.now();

    Product build({
      required String id,
      required String name,
      required ProductCategory category,
      required double salePrice,
      required double costPrice,
      required List<String> imagePaths,
      required int createdDaysAgo,
      required String description,
      int stockQuantity = 0,
      List<VariantOption> options = const <VariantOption>[],
      List<int> variantStock = const <int>[],
      int Function(Map<String, String> values)? imageIndexOf,
    }) {
      final List<ProductImage> images = <ProductImage>[
        for (int index = 0; index < imagePaths.length; index++)
          ProductImage(id: '$id-img-${index + 1}', path: imagePaths[index]),
      ];
      final List<Map<String, String>> combinations = combinationsOf(options);
      assert(
        combinations.length == variantStock.length,
        '$id needs one stock per combination',
      );

      return Product(
        id: id,
        name: name,
        category: category,
        salePrice: salePrice,
        costPrice: costPrice,
        stockQuantity: stockQuantity,
        images: images,
        createdAt: now.subtract(Duration(days: createdDaysAgo)),
        description: description,
        options: options,
        variants: <ProductVariant>[
          for (int index = 0; index < combinations.length; index++)
            ProductVariant.fromValues(
              optionValues: combinations[index],
              stockQuantity: variantStock[index],
              imageId: imageIndexOf == null
                  ? null
                  : images[imageIndexOf(combinations[index])].id,
            ),
        ],
      );
    }

    VariantOption sizes(List<String> values) =>
        VariantOption(name: 'Talla', values: values);

    return <Product>[
      build(
        id: 'p-001',
        name: 'Zapatillas urbanas',
        category: footwear,
        salePrice: 450,
        costPrice: 290,
        imagePaths: <String>[
          AppAssets.sneakersRed,
          AppAssets.sneakersBlue,
          AppAssets.sneakersBlack,
        ],
        createdDaysAgo: 18,
        description:
            'Zapatillas de tejido liviano con suela de goma. Cómodas para '
            'todo el día.',
        options: <VariantOption>[
          const VariantOption(
            name: 'Color',
            values: <String>['Rojo', 'Azul', 'Negro'],
          ),
          sizes(<String>['38', '39', '40', '41', '42']),
        ],
        // Rojo 38–42, Azul 38–42, Negro 38–42.
        variantStock: <int>[1, 2, 3, 1, 0, 0, 1, 2, 1, 0, 0, 0, 1, 0, 0],
        imageIndexOf: (Map<String, String> values) =>
            <String>['Rojo', 'Azul', 'Negro'].indexOf(values['Color']!),
      ),
      build(
        id: 'p-002',
        name: 'Chamarra de cuero',
        category: clothing,
        salePrice: 690,
        costPrice: 420,
        imagePaths: <String>[AppAssets.leatherJacket],
        createdDaysAgo: 40,
        description: 'Cuero sintético con forro interior y cierres metálicos.',
        options: <VariantOption>[
          sizes(<String>['S', 'M', 'L']),
        ],
        variantStock: <int>[0, 1, 1],
      ),
      build(
        id: 'p-003',
        name: 'Polera estampada Original',
        category: clothing,
        salePrice: 89,
        costPrice: 45,
        imagePaths: <String>[AppAssets.tshirtPrint, AppAssets.tshirtPrintRed],
        createdDaysAgo: 12,
        description: 'Algodón peinado 100 %, estampado frontal en serigrafía.',
        options: <VariantOption>[
          const VariantOption(name: 'Color', values: <String>['Azul', 'Rojo']),
          sizes(_clothingSizes),
        ],
        variantStock: <int>[2, 4, 4, 2, 1, 5, 4, 2],
        imageIndexOf: (Map<String, String> values) =>
            values['Color'] == 'Rojo' ? 1 : 0,
      ),
      build(
        id: 'p-004',
        name: 'Chompa de lana',
        category: clothing,
        salePrice: 180,
        costPrice: 95,
        imagePaths: <String>[AppAssets.woolSweater],
        createdDaysAgo: 60,
        description: 'Tejido de lana de oveja, cuello redondo.',
        options: <VariantOption>[
          sizes(<String>['S', 'M', 'L']),
        ],
        variantStock: <int>[0, 0, 0],
      ),
      build(
        id: 'p-005',
        name: 'Cartera de cuero',
        category: accessories,
        salePrice: 380,
        costPrice: 230,
        imagePaths: <String>[
          AppAssets.leatherBag,
          AppAssets.leatherBagBrown,
          AppAssets.leatherBagBlack,
        ],
        createdDaysAgo: 25,
        description:
            'Cartera de mano con correa desmontable y broche metálico.',
        options: const <VariantOption>[
          VariantOption(
            name: 'Color',
            values: <String>['Roja', 'Café', 'Negra'],
          ),
        ],
        variantStock: <int>[1, 2, 1],
        imageIndexOf: (Map<String, String> values) =>
            <String>['Roja', 'Café', 'Negra'].indexOf(values['Color']!),
      ),
      build(
        id: 'p-006',
        name: 'Lentes de sol clásicos',
        category: accessories,
        salePrice: 120,
        costPrice: 55,
        stockQuantity: 14,
        imagePaths: <String>[AppAssets.sunglasses],
        createdDaysAgo: 8,
        description: 'Protección UV400, marco de acetato.',
      ),
      build(
        id: 'p-007',
        name: 'Mochila urbana',
        category: accessories,
        salePrice: 260,
        costPrice: 150,
        stockQuantity: 7,
        imagePaths: <String>[AppAssets.backpack],
        createdDaysAgo: 30,
        description: 'Compartimento acolchado para laptop de hasta 15".',
      ),
      build(
        id: 'p-008',
        name: 'Gorra trucker blanca',
        category: accessories,
        salePrice: 65,
        costPrice: 28,
        stockQuantity: 18,
        imagePaths: <String>[AppAssets.capWhite],
        createdDaysAgo: 5,
        description: 'Malla trasera y cierre regulable.',
      ),
      build(
        id: 'p-009',
        name: 'Chamarra de jean',
        category: clothing,
        salePrice: 320,
        costPrice: 190,
        imagePaths: <String>[AppAssets.denimJacket],
        createdDaysAgo: 22,
        description: 'Jean rígido de lavado clásico con botones metálicos.',
        options: <VariantOption>[sizes(_clothingSizes)],
        variantStock: <int>[1, 2, 2, 1],
      ),
      build(
        id: 'p-010',
        name: 'Zapatillas blancas clásicas',
        category: footwear,
        salePrice: 390,
        costPrice: 240,
        imagePaths: <String>[AppAssets.sneakersWhite],
        createdDaysAgo: 15,
        description: 'Cuero sintético blanco, fáciles de limpiar.',
        options: <VariantOption>[
          sizes(<String>['37', '38', '39', '40', '41']),
        ],
        variantStock: <int>[0, 1, 1, 1, 0],
      ),
      build(
        id: 'p-011',
        name: 'Polera básica',
        category: clothing,
        salePrice: 75,
        costPrice: 38,
        imagePaths: <String>[AppAssets.tshirtBlack, AppAssets.tshirtGray],
        createdDaysAgo: 10,
        description: 'Algodón 100 %, corte regular. La que más se vende.',
        options: <VariantOption>[
          const VariantOption(name: 'Color', values: <String>['Negra', 'Gris']),
          sizes(_clothingSizes),
        ],
        variantStock: <int>[3, 6, 6, 4, 2, 4, 4, 2],
        imageIndexOf: (Map<String, String> values) =>
            values['Color'] == 'Gris' ? 1 : 0,
      ),
      build(
        id: 'p-012',
        name: 'Zapatillas running',
        category: footwear,
        salePrice: 420,
        costPrice: 265,
        imagePaths: <String>[AppAssets.runningShoes],
        createdDaysAgo: 20,
        description: 'Amortiguación en espuma y malla transpirable.',
        options: <VariantOption>[
          sizes(<String>['39', '40', '41', '42', '43']),
        ],
        variantStock: <int>[1, 2, 2, 2, 1],
      ),
      build(
        id: 'p-013',
        name: 'Bomber terracota',
        category: clothing,
        salePrice: 280,
        costPrice: 160,
        imagePaths: <String>[AppAssets.bomberJacket],
        createdDaysAgo: 35,
        description: 'Nylon repelente al agua, puños y cintura en tejido rib.',
        options: <VariantOption>[
          sizes(<String>['M', 'L', 'XL']),
        ],
        variantStock: <int>[3, 4, 2],
      ),
      build(
        id: 'p-014',
        name: 'Billetera de cuero',
        category: accessories,
        salePrice: 95,
        costPrice: 48,
        stockQuantity: 1,
        imagePaths: <String>[AppAssets.wallet],
        createdDaysAgo: 28,
        description: 'Cuero genuino, seis ranuras para tarjetas.',
      ),
    ];
  }
}

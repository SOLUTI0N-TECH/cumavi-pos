import 'package:equatable/equatable.dart';

/// A way a product varies and its possible values: `Talla: S, M, L`.
final class VariantOption extends Equatable {
  const VariantOption({required this.name, required this.values});

  final String name;
  final List<String> values;

  VariantOption copyWith({String? name, List<String>? values}) =>
      VariantOption(name: name ?? this.name, values: values ?? this.values);

  @override
  List<Object?> get props => <Object?>[name, values];
}

/// One sellable combination of values (`Color Rojo` + `Talla 40`) with its
/// own stock and, optionally, one of the product's photos.
final class ProductVariant extends Equatable {
  const ProductVariant({
    required this.id,
    required this.optionValues,
    required this.stockQuantity,
    this.imageId,
    this.sku,
    this.barcode,
  });

  /// Builds a variant whose [id] comes from its values, so the same
  /// combination keeps its identity when the product is edited.
  ProductVariant.fromValues({
    required Map<String, String> optionValues,
    required int stockQuantity,
    String? imageId,
    String? sku,
    String? barcode,
  }) : this(
         id: idFor(optionValues),
         optionValues: optionValues,
         stockQuantity: stockQuantity,
         imageId: imageId,
         sku: sku,
         barcode: barcode,
       );

  /// Unique within its product.
  final String id;

  /// Value per option name, in the product's option order.
  final Map<String, String> optionValues;
  final int stockQuantity;

  /// One of the product's images; `null` shows the main photo.
  final String? imageId;

  /// The seller's own code of this variant (`CAL-001-ROJ-40`).
  final String? sku;

  /// Code on this variant's label; scanning it sells this exact variant.
  final String? barcode;

  bool get hasCodes => sku != null || barcode != null;

  /// `Rojo · 40`
  String get label => optionValues.values.join(' · ');

  bool get isAvailable => stockQuantity > 0;

  /// Whether this variant has every value of [selection].
  bool matches(Map<String, String> selection) => selection.entries.every(
    (MapEntry<String, String> entry) => optionValues[entry.key] == entry.value,
  );

  static String idFor(Map<String, String> optionValues) =>
      optionValues.values.map((String value) => value.toLowerCase()).join('/');

  ProductVariant copyWith({int? stockQuantity, String? imageId}) =>
      ProductVariant(
        id: id,
        optionValues: optionValues,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        imageId: imageId ?? this.imageId,
        sku: sku,
        barcode: barcode,
      );

  /// Same variant without an image (the main photo is shown).
  ProductVariant withoutImage() => ProductVariant(
    id: id,
    optionValues: optionValues,
    stockQuantity: stockQuantity,
    sku: sku,
    barcode: barcode,
  );

  /// Same variant with exactly these codes; `null` removes one.
  ProductVariant withCodes({required String? sku, required String? barcode}) =>
      ProductVariant(
        id: id,
        optionValues: optionValues,
        stockQuantity: stockQuantity,
        imageId: imageId,
        sku: sku,
        barcode: barcode,
      );

  @override
  List<Object?> get props => <Object?>[
    id,
    optionValues,
    stockQuantity,
    imageId,
    sku,
    barcode,
  ];
}

/// Every combination of the options' values, in option order:
/// `Color: Rojo, Azul` × `Talla: S, M` → Rojo·S, Rojo·M, Azul·S, Azul·M.
List<Map<String, String>> combinationsOf(List<VariantOption> options) {
  final List<VariantOption> usable = options
      .where((VariantOption option) => option.values.isNotEmpty)
      .toList();
  if (usable.isEmpty) return const <Map<String, String>>[];

  List<Map<String, String>> combinations = <Map<String, String>>[
    <String, String>{},
  ];
  for (final VariantOption option in usable) {
    combinations = <Map<String, String>>[
      for (final Map<String, String> partial in combinations)
        for (final String value in option.values)
          <String, String>{...partial, option.name: value},
    ];
  }
  return combinations;
}

import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';

/// One product (or one variant of it, e.g. `Rojo · 40`) and its quantity
/// inside the cart.
final class CartLine extends Equatable {
  const CartLine({
    required this.product,
    required this.quantity,
    this.variant,
    this.fixedUnitPrice,
  });

  final Product product;
  final ProductVariant? variant;
  final int quantity;

  /// Price agreed elsewhere (an online order keeps the price the customer
  /// saw); `null` uses the product's current price.
  final double? fixedUnitPrice;

  /// Identifies the line: the same product in two variants makes two lines.
  String get key => keyOf(product.id, variant?.id);

  static String keyOf(String productId, String? variantId) =>
      variantId == null ? productId : '$productId#$variantId';

  double get unitPrice => fixedUnitPrice ?? product.salePrice;

  double get lineTotal => unitPrice * quantity;

  /// Units available for this line: the variant's stock when there is one.
  int get availableStock => variant?.stockQuantity ?? product.stockQuantity;

  /// Photo of the chosen variant, or the product's main one.
  String get imagePath => product.imagePathOf(variant);

  /// Whether another unit can be added without exceeding the stock.
  bool get canIncrement => quantity < availableStock;

  CartLine increment() =>
      canIncrement ? copyWith(quantity: quantity + 1) : this;

  CartLine decrement() =>
      quantity <= 1 ? this : copyWith(quantity: quantity - 1);

  CartLine copyWith({int? quantity}) => CartLine(
    product: product,
    variant: variant,
    quantity: quantity ?? this.quantity,
    fixedUnitPrice: fixedUnitPrice,
  );

  @override
  List<Object?> get props => <Object?>[
    product,
    variant,
    quantity,
    fixedUnitPrice,
  ];
}

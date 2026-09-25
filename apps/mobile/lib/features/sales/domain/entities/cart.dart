import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import 'cart_line.dart';

/// Sale in progress. Immutable: every mutation returns a new [Cart], which
/// keeps the totals consistent and makes the rules easy to unit test.
///
/// Lines are addressed by [CartLine.key]: a product sold in two variants
/// (`Rojo · M`, `Negro · L`) takes two lines.
final class Cart extends Equatable {
  const Cart({this.lines = const <CartLine>[], this.discount = 0});

  const Cart.empty() : this();

  final List<CartLine> lines;

  /// Discount in bolivianos applied to the whole sale.
  final double discount;

  bool get isEmpty => lines.isEmpty;

  bool get isNotEmpty => lines.isNotEmpty;

  /// Number of units, not of lines.
  int get itemCount =>
      lines.fold(0, (int total, CartLine line) => total + line.quantity);

  double get subtotal =>
      lines.fold(0, (double total, CartLine line) => total + line.lineTotal);

  double get total => (subtotal - discount).clamp(0, double.infinity);

  /// Units of a product in the cart, all its variants together.
  int quantityOf(String productId) => lines
      .where((CartLine line) => line.product.id == productId)
      .fold(0, (int total, CartLine line) => total + line.quantity);

  /// Units of one line (a product, or one of its variants).
  int quantityOfLine(String lineKey) =>
      lines
          .where((CartLine line) => line.key == lineKey)
          .firstOrNull
          ?.quantity ??
      0;

  /// Adds [quantity] units of [product] (in [variant] when it has variants),
  /// never beyond the available stock.
  Cart addProduct(
    Product product, {
    ProductVariant? variant,
    int quantity = 1,
  }) {
    // The stock of a product with variants lives in each variant.
    if (product.hasVariants && variant == null) return this;

    final CartLine candidate = CartLine(
      product: product,
      variant: variant,
      quantity: 0,
    );
    final int index = _indexOf(candidate.key);
    final CartLine current = index == -1 ? candidate : lines[index];
    final int target = (current.quantity + quantity).clamp(
      0,
      current.availableStock,
    );
    if (target == current.quantity) return this;

    final CartLine updated = current.copyWith(quantity: target);
    if (index == -1) return copyWith(lines: <CartLine>[...lines, updated]);
    return _replaceLine(index, updated);
  }

  /// Adds one unit to an existing line, respecting the available stock.
  Cart incrementLine(String lineKey) {
    final int index = _indexOf(lineKey);
    if (index == -1) return this;
    return _replaceLine(index, lines[index].increment());
  }

  /// Removes one unit; drops the line when it reaches zero.
  Cart decrementLine(String lineKey) {
    final int index = _indexOf(lineKey);
    if (index == -1) return this;
    final CartLine line = lines[index];
    if (line.quantity <= 1) return removeLine(lineKey);
    return _replaceLine(index, line.decrement());
  }

  Cart removeLine(String lineKey) {
    return copyWith(
      lines: lines.where((CartLine line) => line.key != lineKey).toList(),
    );
  }

  Cart applyDiscount(double value) =>
      copyWith(discount: value.clamp(0, subtotal));

  Cart clear() => const Cart.empty();

  int _indexOf(String lineKey) =>
      lines.indexWhere((CartLine line) => line.key == lineKey);

  Cart _replaceLine(int index, CartLine line) {
    final List<CartLine> updated = List<CartLine>.of(lines);
    updated[index] = line;
    return copyWith(lines: updated);
  }

  Cart copyWith({List<CartLine>? lines, double? discount}) =>
      Cart(lines: lines ?? this.lines, discount: discount ?? this.discount);

  @override
  List<Object?> get props => <Object?>[lines, discount];
}

import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_line.dart';

/// Whether a value (`Talla 38`) can be chosen given the rest of the choice.
enum VariantValueAvailability {
  /// Some variant with this value and the other choices still has units to
  /// add.
  available,

  /// Nothing left together with the other choices, although it still sells
  /// with others: choosing it drops the choices that conflict with it.
  unavailableWithSelection,

  /// No variant with this value has units left to add.
  soldOut;

  bool get isAvailable => this == VariantValueAvailability.available;
}

/// What the seller has chosen so far in the variant picker (`Color Azul` +
/// `Talla 40`).
///
/// Stock is counted net of the units already in the cart, so the picker never
/// offers more than can actually be added.
final class VariantSelection extends Equatable {
  const VariantSelection._({
    required this.product,
    required this.cart,
    required this.values,
  });

  /// Starts with the options that have a single value already chosen: there
  /// is nothing to ask about them.
  factory VariantSelection.initial(Product product, Cart cart) {
    return VariantSelection._(
      product: product,
      cart: cart,
      values: <String, String>{
        for (final VariantOption option in product.options)
          if (option.values.length == 1) option.name: option.values.single,
      },
    );
  }

  final Product product;

  /// Cart at the moment the picker opened.
  final Cart cart;

  /// Chosen value per option name.
  final Map<String, String> values;

  bool get isComplete => product.options.every(
    (VariantOption option) => values.containsKey(option.name),
  );

  /// First option still without a value, the one the picker asks for.
  VariantOption? get missingOption => product.options
      .where((VariantOption option) => !values.containsKey(option.name))
      .firstOrNull;

  /// The chosen variant, once every option has a value.
  ProductVariant? get variant => isComplete
      ? product.variants
            .where((ProductVariant variant) => variant.matches(values))
            .firstOrNull
      : null;

  /// Units of the chosen variant already in the cart.
  int get inCart => switch (variant) {
    final ProductVariant chosen => _inCartOf(chosen),
    null => 0,
  };

  /// Units of the chosen variant that can still be added.
  int get remaining => switch (variant) {
    final ProductVariant chosen => _remainingOf(chosen),
    null => 0,
  };

  bool get canAdd => remaining > 0;

  /// Photo of the choice so far: the variant's, or the one every matching
  /// variant shares (all the `Azul` sizes show the blue photo); the main one
  /// while the choice does not point to a single photo.
  String get imagePath {
    final List<ProductVariant> matching = product.variants
        .where((ProductVariant variant) => variant.matches(values))
        .toList();
    final Set<String?> imageIds = matching
        .map((ProductVariant variant) => variant.imageId)
        .toSet();
    return imageIds.length == 1
        ? product.imagePathOf(matching.first)
        : product.imagePath;
  }

  VariantValueAvailability availabilityOf(String option, String value) {
    if (_hasUnitsLeft(<String, String>{...values, option: value})) {
      return VariantValueAvailability.available;
    }
    if (_hasUnitsLeft(<String, String>{option: value})) {
      return VariantValueAvailability.unavailableWithSelection;
    }
    return VariantValueAvailability.soldOut;
  }

  /// Chooses [value] for [option]. The other choices are kept, in option
  /// order, while they still have units left together with it; the rest are
  /// dropped so the seller never gets stuck on an impossible combination.
  VariantSelection select(String option, String value) {
    Map<String, String> next = <String, String>{option: value};
    for (final VariantOption other in product.options) {
      final String? chosen = values[other.name];
      if (other.name == option || chosen == null) continue;
      final Map<String, String> candidate = <String, String>{
        ...next,
        other.name: chosen,
      };
      if (_hasUnitsLeft(candidate)) next = candidate;
    }
    return VariantSelection._(product: product, cart: cart, values: next);
  }

  int _inCartOf(ProductVariant variant) =>
      cart.quantityOfLine(CartLine.keyOf(product.id, variant.id));

  int _remainingOf(ProductVariant variant) =>
      math.max(0, variant.stockQuantity - _inCartOf(variant));

  bool _hasUnitsLeft(Map<String, String> selection) => product.variants.any(
    (ProductVariant variant) =>
        variant.matches(selection) && _remainingOf(variant) > 0,
  );

  @override
  List<Object?> get props => <Object?>[product, cart, values];
}

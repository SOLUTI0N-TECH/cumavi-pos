import 'product.dart';
import 'product_variant.dart';

/// What a scanned or typed code points at: a product and, when the code
/// belongs to one of its variants, that variant.
final class ProductCodeMatch {
  const ProductCodeMatch({required this.product, this.variant});

  final Product product;

  /// `null` when the code is the product's own; a product with variants
  /// then still needs the seller to pick one.
  final ProductVariant? variant;
}

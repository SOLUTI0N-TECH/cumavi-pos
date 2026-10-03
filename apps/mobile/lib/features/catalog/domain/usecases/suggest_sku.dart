import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../entities/product.dart';
import '../entities/product_variant.dart';
import '../repositories/product_repository.dart';

/// Proposes the next free SKU for a product of a category: three letters of
/// the category and a number, `CAL-004` after `CAL-003`.
final class SuggestSku implements UseCase<String, String> {
  const SuggestSku(this._repository);

  static const String fallbackPrefix = 'PRD';

  final ProductRepository _repository;

  @override
  Future<Result<String>> call(String categoryName) async {
    final String prefix = prefixFor(categoryName);
    final Result<List<Product>> products = await _repository.getProducts();
    if (products case Failed<List<Product>>(:final failure)) {
      return Failed<String>(failure);
    }

    final RegExp pattern = RegExp('^$prefix-(\\d+)');
    int highest = 0;
    for (final Product product in products.valueOrNull!) {
      final List<String?> skus = <String?>[
        product.sku,
        for (final ProductVariant variant in product.variants) variant.sku,
      ];
      for (final String? sku in skus) {
        final int? number = int.tryParse(
          pattern.firstMatch(sku ?? '')?.group(1) ?? '',
        );
        if (number != null && number > highest) highest = number;
      }
    }
    return Success<String>(
      '$prefix-${(highest + 1).toString().padLeft(3, '0')}',
    );
  }

  /// `Calzado` → `CAL`, `Artículos de baño` → `ART`.
  static String prefixFor(String categoryName) {
    final String letters = TextNormalizer.normalize(categoryName)
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z0-9]'), '');
    return letters.length < 3 ? fallbackPrefix : letters.substring(0, 3);
  }

  /// SKU of a variant from its product's: `CAL-004-ROJ-38`.
  static String variantSku(String productSku, ProductVariant variant) {
    final String suffix = variant.optionValues.values
        .map(
          (String value) =>
              TextNormalizer.normalize(value)
                  .toUpperCase()
                  .replaceAll(RegExp('[^A-Z0-9]'), ''),
        )
        .where((String value) => value.isNotEmpty)
        .map((String value) => value.length > 3 ? value.substring(0, 3) : value)
        .join('-');
    return suffix.isEmpty ? productSku : '$productSku-$suffix';
  }
}

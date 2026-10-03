import '../../../../core/error/failure.dart';
import '../entities/product_draft.dart';
import '../entities/product_image.dart';
import '../entities/product_variant.dart';
import 'product_code_rules.dart';

/// Business rules of the product form, shared by create and update.
abstract final class ProductDraftRules {
  static const int minNameLength = 3;

  /// The first broken rule, or `null` when the draft can be stored.
  static Failure? validate(ProductDraft draft) {
    if (draft.name.trim().length < minNameLength) {
      return const ValidationFailure(FailureCode.productNameTooShort);
    }
    if (draft.categoryId.isEmpty) {
      return const ValidationFailure(FailureCode.categoryRequired);
    }
    if (draft.salePrice <= 0) {
      return const ValidationFailure(FailureCode.invalidSalePrice);
    }
    if (draft.costPrice < 0) {
      return const ValidationFailure(FailureCode.negativeCostPrice);
    }
    if (draft.costPrice > draft.salePrice) {
      return const ValidationFailure(FailureCode.costAbovePrice);
    }
    if (draft.stockQuantity < 0 ||
        draft.variants.any(
          (ProductVariant variant) => variant.stockQuantity < 0,
        )) {
      return const ValidationFailure(FailureCode.negativeStock);
    }
    return _validateVariants(draft) ?? ProductCodeRules.validate(draft);
  }

  static Failure? _validateVariants(ProductDraft draft) {
    if (draft.options.isEmpty) return null;

    final Set<String> names = <String>{};
    for (final VariantOption option in draft.options) {
      final String name = option.name.trim().toLowerCase();
      final Set<String> values = option.values
          .map((String value) => value.trim().toLowerCase())
          .toSet();
      final bool valid =
          name.isNotEmpty &&
          names.add(name) &&
          option.values.isNotEmpty &&
          values.length == option.values.length &&
          !values.contains('');
      if (!valid) {
        return const ValidationFailure(FailureCode.incompleteVariantOptions);
      }
    }

    final Set<String> imageIds = draft.images
        .map((ProductImage image) => image.id)
        .toSet();
    final bool imagesExist = draft.variants.every(
      (ProductVariant variant) =>
          variant.imageId == null || imageIds.contains(variant.imageId),
    );
    if (draft.variants.isEmpty || !imagesExist) {
      return const ValidationFailure(FailureCode.incompleteVariantOptions);
    }
    return null;
  }
}

import '../../../../core/error/failure.dart';
import '../entities/product_draft.dart';
import '../entities/product_variant.dart';

/// Rules of the SKU (the seller's own code) and the barcode printed on the
/// label, for a product and each of its variants.
///
/// Codes are stored and compared trimmed, in capitals and without spaces,
/// so `abc 123` typed by hand finds the `ABC123` a scanner reads.
abstract final class ProductCodeRules {
  static const int maxLength = 32;

  /// Letters without accents, digits, `-`, `_` and `.`; 2–32 characters.
  static final RegExp _sku = RegExp(r'^[A-Z0-9._-]{2,32}$');

  /// EAN/UPC digits or Code 128/39 text; 4–32 characters.
  static final RegExp _barcode = RegExp(r'^[A-Z0-9./-]{4,32}$');

  static String normalize(String code) =>
      code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');

  /// The normalized code, or `null` when [code] is blank.
  static String? normalizeOrNull(String? code) {
    final String normalized = code == null ? '' : normalize(code);
    return normalized.isEmpty ? null : normalized;
  }

  /// A blank SKU is valid: codes are optional.
  static bool isValidSku(String? sku) {
    final String? normalized = normalizeOrNull(sku);
    return normalized == null || _sku.hasMatch(normalized);
  }

  /// A blank barcode is valid: codes are optional.
  static bool isValidBarcode(String? barcode) {
    final String? normalized = normalizeOrNull(barcode);
    return normalized == null || _barcode.hasMatch(normalized);
  }

  /// Every code of [draft] is well formed and none repeats inside the
  /// product. Codes of other products are checked when storing.
  static Failure? validate(ProductDraft draft) {
    final List<String?> skus = <String?>[
      draft.sku,
      for (final ProductVariant variant in draft.variants) variant.sku,
    ];
    final List<String?> barcodes = <String?>[
      draft.barcode,
      for (final ProductVariant variant in draft.variants) variant.barcode,
    ];
    if (!skus.every(isValidSku)) {
      return const ValidationFailure(FailureCode.invalidSku);
    }
    if (!barcodes.every(isValidBarcode)) {
      return const ValidationFailure(FailureCode.invalidBarcode);
    }

    final Set<String> seen = <String>{};
    for (final String? code in <String?>[...skus, ...barcodes]) {
      final String? normalized = normalizeOrNull(code);
      if (normalized != null && !seen.add(normalized)) {
        return ValidationFailure(
          FailureCode.productCodeRepeated,
          detail: normalized,
        );
      }
    }
    return null;
  }
}

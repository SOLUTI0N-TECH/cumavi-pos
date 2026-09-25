import 'package:equatable/equatable.dart';

/// Snapshot of a sold product. It copies the name, the variant and the price
/// so a later catalog edit never rewrites history on a printed receipt.
final class SaleLine extends Equatable {
  const SaleLine({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.variantId,
    this.variantLabel,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String? variantId;

  /// `Rojo · 40`, printed under the product name.
  final String? variantLabel;

  double get total => unitPrice * quantity;

  @override
  List<Object?> get props => <Object?>[
    productId,
    productName,
    unitPrice,
    quantity,
    variantId,
    variantLabel,
  ];
}

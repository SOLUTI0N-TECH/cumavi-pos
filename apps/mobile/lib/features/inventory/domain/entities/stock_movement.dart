import 'package:equatable/equatable.dart';

/// Why the stock of a product changed.
enum StockMovementType {
  /// The stock a product was created with.
  initial,

  /// Goods received from a supplier.
  purchase,

  /// A manual correction: a count, damaged or lost units…
  adjustment,

  /// Units sold.
  sale,

  /// A cancelled sale gives its units back (feature 5).
  cancellation,

  /// A customer returned units (feature 5).
  saleReturn,
}

/// Reason of an [StockMovementType.adjustment]; required for them.
enum AdjustmentReason { count, damage, loss, other }

/// One change of the stock of a product (or of one of its variants), with
/// the stock it left. Names are copied so the history reads the same after
/// the product is renamed.
final class StockMovement extends Equatable {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.delta,
    required this.stockAfter,
    required this.type,
    required this.userName,
    required this.createdAt,
    this.variantId,
    this.variantLabel,
    this.reason,
    this.note,
    this.unitCost,
    this.saleId,
  });

  final String id;
  final String productId;
  final String productName;
  final String? variantId;

  /// `Rojo · 40`
  final String? variantLabel;

  /// Units added (positive) or taken (negative).
  final int delta;

  /// Stock of the product, or of the variant, right after this movement.
  final int stockAfter;
  final StockMovementType type;
  final AdjustmentReason? reason;

  /// Free text: the supplier of a purchase, what happened in an adjustment.
  final String? note;

  /// What each unit cost, for purchases.
  final double? unitCost;

  /// The sale behind a sale, cancellation or return movement.
  final String? saleId;
  final String userName;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    productId,
    productName,
    variantId,
    variantLabel,
    delta,
    stockAfter,
    type,
    reason,
    note,
    unitCost,
    saleId,
    userName,
    createdAt,
  ];
}

/// A movement to record. The store sets the id, the resulting stock, the
/// names, the user and the time.
final class StockMovementDraft extends Equatable {
  const StockMovementDraft({
    required this.productId,
    required this.delta,
    required this.type,
    this.variantId,
    this.reason,
    this.note,
    this.unitCost,
    this.saleId,
  });

  final String productId;
  final String? variantId;
  final int delta;
  final StockMovementType type;
  final AdjustmentReason? reason;
  final String? note;
  final double? unitCost;
  final String? saleId;

  @override
  List<Object?> get props => <Object?>[
    productId,
    variantId,
    delta,
    type,
    reason,
    note,
    unitCost,
    saleId,
  ];
}

/// Filters of the movements history; every field is optional.
final class StockMovementQuery extends Equatable {
  const StockMovementQuery({
    this.productId,
    this.variantId,
    this.types,
    this.from,
    this.limit,
  });

  final String? productId;
  final String? variantId;

  /// `null` means every type.
  final Set<StockMovementType>? types;

  /// Movements at or after this moment.
  final DateTime? from;

  /// At most this many, the newest.
  final int? limit;

  bool matches(StockMovement movement) {
    final Set<StockMovementType>? types = this.types;
    final DateTime? from = this.from;
    return (productId == null || movement.productId == productId) &&
        (variantId == null || movement.variantId == variantId) &&
        (types == null || types.contains(movement.type)) &&
        (from == null || !movement.createdAt.isBefore(from));
  }

  @override
  List<Object?> get props => <Object?>[
    productId,
    variantId,
    types,
    from,
    limit,
  ];
}

import 'package:equatable/equatable.dart';

/// Single-level product category (the POS keeps one hierarchy level only).
/// The seller creates, orders and archives them.
final class ProductCategory extends Equatable {
  const ProductCategory({
    required this.id,
    required this.name,
    this.sortOrder = 0,
    this.isArchived = false,
  });

  final String id;
  final String name;

  /// Position chosen by the seller in filters and pickers.
  final int sortOrder;

  /// Archived categories leave pickers and filters but their products keep
  /// them, so history stays consistent. There is no hard delete.
  final bool isArchived;

  ProductCategory copyWith({String? name, int? sortOrder, bool? isArchived}) {
    return ProductCategory(
      id: id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, sortOrder, isArchived];
}

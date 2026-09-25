import 'package:equatable/equatable.dart';

/// Single-level product category (the POS keeps one hierarchy level only).
final class ProductCategory extends Equatable {
  const ProductCategory({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => <Object?>[id, name];
}

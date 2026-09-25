import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';

enum CatalogStatus { loading, ready, failure }

final class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.loading,
    this.products = const <Product>[],
    this.categories = const <ProductCategory>[],
    this.categoryCounts = const <String, int>{},
    this.query = '',
    this.selectedCategoryId,
    this.failure,
  });

  final CatalogStatus status;
  final List<Product> products;
  final List<ProductCategory> categories;

  /// Products per category id, used by the filter chips.
  final Map<String, int> categoryCounts;
  final String query;

  /// `null` means "Todos".
  final String? selectedCategoryId;
  final Failure? failure;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? products,
    List<ProductCategory>? categories,
    Map<String, int>? categoryCounts,
    String? query,
    String? selectedCategoryId,
    bool clearCategory = false,
    Failure? failure,
  }) {
    return CatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      categoryCounts: categoryCounts ?? this.categoryCounts,
      query: query ?? this.query,
      selectedCategoryId: clearCategory
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    products,
    categories,
    categoryCounts,
    query,
    selectedCategoryId,
    failure,
  ];
}

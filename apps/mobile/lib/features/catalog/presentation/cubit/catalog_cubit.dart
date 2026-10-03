import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_code_match.dart';
import '../../domain/usecases/find_product_by_code.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products.dart';
import 'catalog_state.dart';

/// Catalog search used while selling: free text plus a single category
/// filter, the only hierarchy level the POS has.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({
    required GetProducts getProducts,
    required GetCategories getCategories,
    required FindProductByCode findProductByCode,
  }) : _getProducts = getProducts,
       _getCategories = getCategories,
       _findProductByCode = findProductByCode,
       super(const CatalogState());

  final GetProducts _getProducts;
  final GetCategories _getCategories;
  final FindProductByCode _findProductByCode;

  /// The product or variant with a scanned or typed [code]. The screen
  /// decides what to do with it (sell it, open it…), so it is not state.
  Future<Result<ProductCodeMatch>> findByCode(String code) =>
      _findProductByCode(code);

  Future<void> load({String? categoryId}) async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        selectedCategoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );

    final Result<List<ProductCategory>> categoriesResult = await _getCategories(
      const NoParams(),
    );
    if (categoriesResult case Success<List<ProductCategory>>(
      :final List<ProductCategory> value,
    )) {
      emit(state.copyWith(categories: value));
    }

    await _refreshCategoryCounts();
    await _search();
  }

  Future<void> queryChanged(String query) async {
    emit(state.copyWith(query: query));
    await _search();
  }

  Future<void> categorySelected(String? categoryId) async {
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        clearCategory: categoryId == null,
      ),
    );
    await _search();
  }

  Future<void> _search() async {
    final Result<List<Product>> result = await _getProducts(
      ProductQuery(query: state.query, categoryId: state.selectedCategoryId),
    );

    switch (result) {
      case Success<List<Product>>(:final List<Product> value):
        emit(state.copyWith(status: CatalogStatus.ready, products: value));
      case Failed<List<Product>>(:final failure):
        emit(state.copyWith(status: CatalogStatus.failure, failure: failure));
    }
  }

  Future<void> _refreshCategoryCounts() async {
    final Result<List<Product>> result = await _getProducts(
      const ProductQuery(),
    );
    if (result case Success<List<Product>>(:final List<Product> value)) {
      final Map<String, int> counts = <String, int>{};
      for (final Product product in value) {
        counts.update(
          product.category.id,
          (int current) => current + 1,
          ifAbsent: () => 1,
        );
      }
      emit(state.copyWith(categoryCounts: counts));
    }
  }
}

import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';
import 'category_rules.dart';

/// A category with how many products it has, for the management screen.
final class CategoryOverview extends Equatable {
  const CategoryOverview({required this.category, required this.productCount});

  final ProductCategory category;
  final int productCount;

  @override
  List<Object?> get props => <Object?>[category, productCount];
}

/// Every category, archived ones included, with its product count.
final class GetCategoryOverview
    implements UseCase<List<CategoryOverview>, NoParams> {
  const GetCategoryOverview(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<CategoryOverview>>> call(NoParams input) async {
    final Result<List<ProductCategory>> categories = await _repository
        .getCategories(includeArchived: true);
    final Result<List<Product>> products = await _repository.getProducts();

    return switch ((categories, products)) {
      (
        Success<List<ProductCategory>>(
          value: final List<ProductCategory> categories,
        ),
        Success<List<Product>>(value: final List<Product> products),
      ) =>
        Success<List<CategoryOverview>>(<CategoryOverview>[
          for (final ProductCategory category in categories)
            CategoryOverview(
              category: category,
              productCount: products
                  .where(
                    (Product product) => product.category.id == category.id,
                  )
                  .length,
            ),
        ]),
      (Failed<List<ProductCategory>>(:final Failure failure), _) ||
      (
        _,
        Failed<List<Product>>(:final Failure failure),
      ) => Failed<List<CategoryOverview>>(failure),
    };
  }
}

final class CreateCategory implements UseCase<ProductCategory, String> {
  const CreateCategory(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<ProductCategory>> call(String name) async {
    final Failure? invalid = CategoryRules.validateName(name);
    if (invalid != null) return Failed<ProductCategory>(invalid);
    return _repository.createCategory(name.trim());
  }
}

/// Input of [RenameCategory].
final class CategoryRename {
  const CategoryRename({required this.categoryId, required this.name});

  final String categoryId;
  final String name;
}

/// Renames a category; its products show the new name everywhere.
final class RenameCategory implements UseCase<ProductCategory, CategoryRename> {
  const RenameCategory(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<ProductCategory>> call(CategoryRename input) async {
    final Failure? invalid = CategoryRules.validateName(input.name);
    if (invalid != null) return Failed<ProductCategory>(invalid);
    return _repository.renameCategory(input.categoryId, input.name.trim());
  }
}

/// Saves the order the seller dragged the categories into.
final class ReorderCategories implements UseCase<void, List<String>> {
  const ReorderCategories(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<void>> call(List<String> orderedIds) =>
      _repository.reorderCategories(orderedIds);
}

/// Input of [SetCategoryArchived].
final class CategoryArchiving {
  const CategoryArchiving({required this.categoryId, required this.archived});

  final String categoryId;
  final bool archived;
}

/// Archives a category (it leaves pickers and filters, its products keep
/// it) or restores it.
final class SetCategoryArchived
    implements UseCase<ProductCategory, CategoryArchiving> {
  const SetCategoryArchived(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<ProductCategory>> call(CategoryArchiving input) => _repository
      .setCategoryArchived(input.categoryId, archived: input.archived);
}

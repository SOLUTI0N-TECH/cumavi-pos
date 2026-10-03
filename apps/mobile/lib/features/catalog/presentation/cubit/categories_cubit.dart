import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/usecases/manage_categories.dart';

enum CategoriesStatus { loading, ready, failure }

final class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = CategoriesStatus.loading,
    this.items = const <CategoryOverview>[],
    this.failure,
  });

  final CategoriesStatus status;

  /// Every category with its product count, archived ones included.
  final List<CategoryOverview> items;
  final Failure? failure;

  /// In the seller's order.
  List<CategoryOverview> get active => items
      .where((CategoryOverview item) => !item.category.isArchived)
      .toList();

  List<CategoryOverview> get archived =>
      items.where((CategoryOverview item) => item.category.isArchived).toList();

  @override
  List<Object?> get props => <Object?>[status, items, failure];
}

/// The "Categorías" screen: create, rename, reorder, archive and restore.
/// Actions return the failure (or `null`) so the screen can answer inline.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({
    required GetCategoryOverview getCategoryOverview,
    required CreateCategory createCategory,
    required RenameCategory renameCategory,
    required ReorderCategories reorderCategories,
    required SetCategoryArchived setCategoryArchived,
  }) : _getCategoryOverview = getCategoryOverview,
       _createCategory = createCategory,
       _renameCategory = renameCategory,
       _reorderCategories = reorderCategories,
       _setCategoryArchived = setCategoryArchived,
       super(const CategoriesState());

  final GetCategoryOverview _getCategoryOverview;
  final CreateCategory _createCategory;
  final RenameCategory _renameCategory;
  final ReorderCategories _reorderCategories;
  final SetCategoryArchived _setCategoryArchived;

  Future<void> load() async {
    switch (await _getCategoryOverview(const NoParams())) {
      case Success<List<CategoryOverview>>(:final List<CategoryOverview> value):
        emit(CategoriesState(status: CategoriesStatus.ready, items: value));
      case Failed<List<CategoryOverview>>(:final failure):
        emit(
          CategoriesState(
            status: CategoriesStatus.failure,
            items: state.items,
            failure: failure,
          ),
        );
    }
  }

  Future<Failure?> create(String name) =>
      _runAndReload(() => _createCategory(name));

  Future<Failure?> rename(String categoryId, String name) => _runAndReload(
    () => _renameCategory(CategoryRename(categoryId: categoryId, name: name)),
  );

  Future<Failure?> setArchived(String categoryId, {required bool archived}) =>
      _runAndReload(
        () => _setCategoryArchived(
          CategoryArchiving(categoryId: categoryId, archived: archived),
        ),
      );

  /// Moves an active category from [oldIndex] to its final position
  /// [newIndex]. The list changes right away; it is reloaded if saving fails.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final List<CategoryOverview> active = state.active;
    final CategoryOverview moved = active.removeAt(oldIndex);
    active.insert(newIndex, moved);
    emit(
      CategoriesState(
        status: state.status,
        items: <CategoryOverview>[
          for (int i = 0; i < active.length; i++)
            CategoryOverview(
              category: active[i].category.copyWith(sortOrder: i),
              productCount: active[i].productCount,
            ),
          ...state.archived,
        ],
      ),
    );

    final Result<void> result = await _reorderCategories(<String>[
      for (final CategoryOverview item in active) item.category.id,
    ]);
    if (result case Failed<void>(:final failure)) {
      emit(
        CategoriesState(
          status: state.status,
          items: state.items,
          failure: failure,
        ),
      );
      await load();
    }
  }

  Future<Failure?> _runAndReload(
    Future<Result<ProductCategory>> Function() action,
  ) async {
    final Result<ProductCategory> result = await action();
    if (result case Failed<ProductCategory>(:final failure)) return failure;
    await load();
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/usecases/manage_categories.dart';
import '../cubit/categories_cubit.dart';
import '../widgets/category_name_sheet.dart';

/// "Categorías": the seller's own categories, in the order they want to see
/// them when selling. Archived ones can be restored.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().load();
  }

  void _toast(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  Future<void> _create() async {
    final AppLocalizations l10n = context.l10n;
    final bool created = await CategoryNameSheet.show(
      context,
      title: l10n.catalogCategoriesNew,
      submitLabel: l10n.catalogCategoriesCreate,
      onSubmit: context.read<CategoriesCubit>().create,
    );
    if (created && mounted) _toast(l10n.catalogCategoriesCreated);
  }

  Future<void> _rename(ProductCategory category) async {
    final AppLocalizations l10n = context.l10n;
    final CategoriesCubit cubit = context.read<CategoriesCubit>();
    final bool renamed = await CategoryNameSheet.show(
      context,
      title: l10n.catalogCategoriesRenameTitle,
      submitLabel: l10n.commonSave,
      initialName: category.name,
      onSubmit: (String name) => cubit.rename(category.id, name),
    );
    if (renamed && mounted) _toast(l10n.catalogCategoriesRenamed);
  }

  Future<void> _archive(CategoryOverview item) async {
    final AppLocalizations l10n = context.l10n;
    final CategoriesCubit cubit = context.read<CategoriesCubit>();
    if (item.productCount > 0) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(l10n.catalogCategoriesArchiveTitle(item.category.name)),
          content: Text(
            l10n.catalogCategoriesArchiveMessage(item.productCount),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.catalogCategoriesArchive),
            ),
          ],
        ),
      );
      if (!(confirmed ?? false)) return;
    }
    final Failure? failure = await cubit.setArchived(
      item.category.id,
      archived: true,
    );
    if (!mounted) return;
    if (failure != null) {
      _toast(failure.localizedMessage(l10n));
      return;
    }
    _toast(
      l10n.catalogCategoriesArchived,
      action: SnackBarAction(
        label: l10n.catalogCategoriesUndo,
        onPressed: () => cubit.setArchived(item.category.id, archived: false),
      ),
    );
  }

  Future<void> _restore(ProductCategory category) async {
    final AppLocalizations l10n = context.l10n;
    final Failure? failure = await context.read<CategoriesCubit>().setArchived(
      category.id,
      archived: false,
    );
    if (!mounted) return;
    _toast(failure?.localizedMessage(l10n) ?? l10n.catalogCategoriesRestored);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      // As the bottom bar, snack bars float above it instead of covering it.
      bottomNavigationBar: _NewCategoryFooter(onPressed: _create),
      body: SafeArea(
        child: BlocConsumer<CategoriesCubit, CategoriesState>(
          listenWhen: (CategoriesState previous, CategoriesState current) =>
              current.failure != null && previous.failure != current.failure,
          listener: (BuildContext context, CategoriesState state) =>
              _toast(state.failure!.localizedMessage(l10n)),
          builder: (BuildContext context, CategoriesState state) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                  ),
                  child: PushedScreenHeader(
                    title: l10n.catalogCategoriesTitle,
                    subtitle: l10n.catalogCategoriesSubtitle,
                    onBack: widget.onBack,
                  ),
                ),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, CategoriesState state) {
    final AppLocalizations l10n = context.l10n;
    if (state.status == CategoriesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == CategoriesStatus.failure && state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: l10n.failureUnexpected,
          message: l10n.catalogCategoriesSubtitle,
          action: TextButton(
            onPressed: context.read<CategoriesCubit>().load,
            child: Text(l10n.commonRetry),
          ),
        ),
      );
    }
    if (state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.category_outlined,
          title: l10n.catalogCategoriesEmptyTitle,
          message: l10n.catalogCategoriesEmptyMessage,
        ),
      );
    }

    final List<CategoryOverview> active = state.active;
    final List<CategoryOverview> archived = state.archived;

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      buildDefaultDragHandles: false,
      itemCount: active.length,
      onReorderItem: context.read<CategoriesCubit>().reorder,
      proxyDecorator: (Widget child, int index, Animation<double> animation) =>
          Material(
            color: Colors.transparent,
            elevation: 6,
            shadowColor: AppColors.ink.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: child,
          ),
      itemBuilder: (BuildContext context, int index) {
        final CategoryOverview item = active[index];
        return Padding(
          key: ValueKey<String>(item.category.id),
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _CategoryTile(
            item: item,
            dragIndex: index,
            onRename: () => _rename(item.category),
            onArchive: () => _archive(item),
          ),
        );
      },
      footer: archived.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.xs,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    l10n.catalogCategoriesArchivedSection.toUpperCase(),
                    style: AppTextStyles.captionSmallStrong.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                for (final CategoryOverview item in archived)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ArchivedTile(
                      item: item,
                      onRestore: () => _restore(item.category),
                    ),
                  ),
              ],
            ),
    );
  }
}

enum _CategoryAction { rename, archive }

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.item,
    required this.dragIndex,
    required this.onRename,
    required this.onArchive,
  });

  final CategoryOverview item;
  final int dragIndex;
  final VoidCallback onRename;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onRename,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              ReorderableDragStartListener(
                index: dragIndex,
                child: Tooltip(
                  message: l10n.catalogCategoriesDragHandle,
                  child: const SizedBox.square(
                    dimension: 48,
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: AppColors.textPlaceholder,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong,
                    ),
                    Text(
                      l10n.catalogCategoriesProductCount(item.productCount),
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_CategoryAction>(
                tooltip: l10n.catalogCategoriesMenu(item.category.name),
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (_CategoryAction action) => switch (action) {
                  _CategoryAction.rename => onRename(),
                  _CategoryAction.archive => onArchive(),
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<_CategoryAction>>[
                      PopupMenuItem<_CategoryAction>(
                        value: _CategoryAction.rename,
                        child: Text(l10n.catalogCategoriesRename),
                      ),
                      PopupMenuItem<_CategoryAction>(
                        value: _CategoryAction.archive,
                        child: Text(l10n.catalogCategoriesArchive),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedTile extends StatelessWidget {
  const _ArchivedTile({required this.item, required this.onRestore});

  final CategoryOverview item;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  l10n.catalogCategoriesProductCount(item.productCount),
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.unarchive_outlined, size: 18),
            label: Text(l10n.catalogCategoriesRestore),
          ),
        ],
      ),
    );
  }
}

class _NewCategoryFooter extends StatelessWidget {
  const _NewCategoryFooter({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          child: PrimaryButton(
            label: context.l10n.catalogCategoriesNew,
            icon: Icons.add_rounded,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

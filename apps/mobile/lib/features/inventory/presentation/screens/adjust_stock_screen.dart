import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/stock_usecases.dart';
import '../cubit/adjust_stock_cubit.dart';
import '../widgets/stock_movement_tile.dart';

/// "Ajustar stock": count the shelf, or add or remove units, always with a
/// reason so the history explains every change.
class AdjustStockScreen extends StatefulWidget {
  const AdjustStockScreen({
    required this.onClose,
    required this.onSaved,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onSaved;

  @override
  State<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends State<AdjustStockScreen> {
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AdjustStockCubit>().load();
  }

  @override
  void dispose() {
    _quantity.dispose();
    _note.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, AdjustStockState state) {
    if (state.status == AdjustStockStatus.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.inventoryAdjustSaved)),
      );
      widget.onSaved();
      return;
    }
    if (state.failure case final failure?
        when state.status == AdjustStockStatus.editing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(context.l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AdjustStockCubit cubit = context.read<AdjustStockCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AdjustStockCubit, AdjustStockState>(
          listener: _onState,
          builder: (BuildContext context, AdjustStockState state) {
            final Product? product = state.product;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: PushedScreenHeader(
                    title: l10n.inventoryAdjustTitle,
                    subtitle: product?.name,
                    onBack: widget.onClose,
                    isCloseAction: true,
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    AdjustStockStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    AdjustStockStatus.failure => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: EmptyStateView(
                        icon: Icons.inventory_2_outlined,
                        title: l10n.catalogDetailLoadErrorTitle,
                        message:
                            state.failure?.localizedMessage(l10n) ??
                            l10n.failureUnexpected,
                      ),
                    ),
                    _ => _form(context, cubit, state, product!),
                  },
                ),
                if (product != null)
                  _Footer(
                    child: PrimaryButton(
                      label: l10n.inventoryAdjustSave,
                      icon: Icons.check_rounded,
                      isLoading: state.status == AdjustStockStatus.saving,
                      onPressed: state.canSubmit ? cubit.submit : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _form(
    BuildContext context,
    AdjustStockCubit cubit,
    AdjustStockState state,
    Product product,
  ) {
    final AppLocalizations l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (product.hasVariants) ...<Widget>[
                LabeledField(
                  label: l10n.inventoryVariantLabel,
                  child: DropdownButtonFormField<String>(
                    initialValue: state.variantId,
                    isExpanded: true,
                    items: <DropdownMenuItem<String>>[
                      for (final ProductVariant variant in product.variants)
                        DropdownMenuItem<String>(
                          value: variant.id,
                          child: Text(
                            l10n.inventoryVariantWithStock(
                              variant.label,
                              variant.stockQuantity,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (String? id) {
                      if (id != null) cubit.variantSelected(id);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              SegmentedButton<AdjustmentMode>(
                showSelectedIcon: false,
                segments: <ButtonSegment<AdjustmentMode>>[
                  ButtonSegment<AdjustmentMode>(
                    value: AdjustmentMode.count,
                    label: Text(l10n.inventoryModeCount),
                  ),
                  ButtonSegment<AdjustmentMode>(
                    value: AdjustmentMode.add,
                    label: Text(l10n.inventoryModeAdd),
                  ),
                  ButtonSegment<AdjustmentMode>(
                    value: AdjustmentMode.remove,
                    label: Text(l10n.inventoryModeRemove),
                  ),
                ],
                selected: <AdjustmentMode>{state.mode},
                onSelectionChanged: (Set<AdjustmentMode> selection) =>
                    cubit.modeSelected(selection.single),
              ),
              const SizedBox(height: AppSpacing.lg),
              LabeledField(
                label: switch (state.mode) {
                  AdjustmentMode.count => l10n.inventoryQuantityCounted,
                  AdjustmentMode.add => l10n.inventoryQuantityToAdd,
                  AdjustmentMode.remove => l10n.inventoryQuantityToRemove,
                },
                child: TextField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (String value) =>
                      cubit.quantityChanged(int.tryParse(value)),
                  decoration: InputDecoration(
                    hintText: l10n.inventoryQuantityHint,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _StockPreview(state: state),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(l10n.inventoryReasonTitle, style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final AdjustmentReason reason in AdjustmentReason.values)
                    ChoiceChip(
                      label: Text(reason.label(l10n)),
                      selected: state.reason == reason,
                      onSelected: (_) => cubit.reasonSelected(reason),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LabeledField(
                label: l10n.inventoryNoteLabel,
                optionalText: l10n.catalogProductFormOptional,
                child: TextField(
                  controller: _note,
                  onChanged: cubit.noteChanged,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.inventoryAdjustNoteHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// `6 → 4 (−2)`: what the adjustment will leave.
class _StockPreview extends StatelessWidget {
  const _StockPreview({required this.state});

  final AdjustStockState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final int delta = state.delta;
    final bool invalid = state.newStock < 0;
    final Color tint = invalid || delta < 0
        ? AppColors.errorText
        : delta > 0
        ? AppColors.successText
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.inventoryCurrentStock,
                  style: AppTextStyles.captionSmall,
                ),
                Text(
                  '${state.currentStock}',
                  style: AppTextStyles.bodyLargeStrong,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.textSecondary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(l10n.inventoryNewStock, style: AppTextStyles.captionSmall),
                Text(
                  invalid
                      ? l10n.inventoryNotEnoughStock
                      : delta == 0
                      ? '${state.newStock}'
                      : '${state.newStock} (${delta > 0 ? '+' : ''}$delta)',
                  style: AppTextStyles.bodyLargeStrong.copyWith(color: tint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          AppSpacing.md,
          AppSpacing.pageHorizontal,
          AppSpacing.lg,
        ),
        child: child,
      ),
    );
  }
}

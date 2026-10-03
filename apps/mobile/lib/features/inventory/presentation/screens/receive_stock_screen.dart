import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_code_match.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/presentation/scanner/barcode_camera.dart';
import '../cubit/receive_stock_cubit.dart';
import '../widgets/product_picker_sheet.dart';

/// "Ingreso de mercadería": the products that arrived, their units and,
/// optionally, what each unit cost and who sent them.
class ReceiveStockScreen extends StatefulWidget {
  const ReceiveStockScreen({
    required this.onClose,
    required this.onSaved,
    this.initialProductId,
    this.onScan,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onSaved;

  /// Starts the receipt with this product ("Ingreso" on its detail).
  final String? initialProductId;

  /// Opens the scanner; without it there is no scan button.
  final ScanCode? onScan;

  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  final TextEditingController _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ReceiveStockCubit cubit = context.read<ReceiveStockCubit>();
    final Product? product = await cubit.load(
      productId: widget.initialProductId,
    );
    if (product != null && product.hasVariants && mounted) {
      await _pickVariantOf(product);
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickVariantOf(Product product) async {
    final ReceiveStockCubit cubit = context.read<ReceiveStockCubit>();
    final ProductVariant? variant = await ProductPickerSheet.pickVariant(
      context,
      product,
    );
    if (variant != null) cubit.addLine(product, variant: variant);
  }

  Future<void> _addProduct() async {
    final ReceiveStockCubit cubit = context.read<ReceiveStockCubit>();
    final PickedProduct? picked = await ProductPickerSheet.show(
      context,
      products: cubit.state.catalog,
    );
    if (picked != null) cubit.addLine(picked.product, variant: picked.variant);
  }

  Future<void> _scan(ScanCode scan) async {
    final ReceiveStockCubit cubit = context.read<ReceiveStockCubit>();
    final String? code = await scan();
    if (code == null || !mounted) return;
    switch (await cubit.addByCode(code)) {
      case Success<ProductCodeMatch>(:final ProductCodeMatch value)
          when value.variant == null && value.product.hasVariants:
        if (mounted) await _pickVariantOf(value.product);
      case Success<ProductCodeMatch>():
        break;
      case Failed<ProductCodeMatch>(:final failure):
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.localizedMessage(context.l10n))),
        );
    }
  }

  void _onState(BuildContext context, ReceiveStockState state) {
    if (state.status == ReceiveStockStatus.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.inventoryReceiveSaved(state.totalUnits)),
        ),
      );
      widget.onSaved();
      return;
    }
    if (state.failure case final failure?) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(context.l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ReceiveStockCubit cubit = context.read<ReceiveStockCubit>();
    final ScanCode? scan = widget.onScan;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ReceiveStockCubit, ReceiveStockState>(
          listenWhen: (ReceiveStockState previous, ReceiveStockState current) =>
              previous.status != current.status ||
              previous.failure != current.failure,
          listener: _onState,
          builder: (BuildContext context, ReceiveStockState state) {
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
                    title: l10n.inventoryReceiveTitle,
                    subtitle: l10n.inventoryReceiveSubtitle,
                    onBack: widget.onClose,
                    isCloseAction: true,
                  ),
                ),
                Expanded(
                  child: state.status == ReceiveStockStatus.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pageHorizontal,
                            AppSpacing.xxl,
                          ),
                          children: <Widget>[
                            if (state.lines.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xl,
                                ),
                                child: EmptyStateView(
                                  icon: Icons.move_to_inbox_rounded,
                                  title: l10n.inventoryReceiveEmptyTitle,
                                  message: l10n.inventoryReceiveEmptyMessage,
                                ),
                              ),
                            for (int i = 0; i < state.lines.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: _LineCard(
                                  key: ValueKey<String>(
                                    '${state.lines[i].product.id}/'
                                    '${state.lines[i].variant?.id}',
                                  ),
                                  line: state.lines[i],
                                  onQuantity: (int quantity) =>
                                      cubit.quantityChanged(i, quantity),
                                  onUnitCost: (double? cost) =>
                                      cubit.unitCostChanged(i, cost),
                                  onRemove: () => cubit.removeLine(i),
                                ),
                              ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _addProduct,
                                    icon: const Icon(Icons.add_rounded),
                                    label: Text(
                                      l10n.inventoryReceiveAddProduct,
                                    ),
                                  ),
                                ),
                                if (scan != null) ...<Widget>[
                                  const SizedBox(width: AppSpacing.sm),
                                  IconButton.outlined(
                                    tooltip: l10n.commonScanBarcodeTooltip,
                                    onPressed: () => _scan(scan),
                                    icon: const Icon(
                                      Icons.qr_code_scanner_rounded,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            LabeledField(
                              label: l10n.inventorySupplierLabel,
                              optionalText: l10n.catalogProductFormOptional,
                              child: TextField(
                                controller: _note,
                                onChanged: cubit.noteChanged,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintText: l10n.inventorySupplierHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                DecoratedBox(
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
                    child: PrimaryButton(
                      label: state.lines.isEmpty
                          ? l10n.inventoryReceiveSave
                          : l10n.inventoryReceiveSaveUnits(state.totalUnits),
                      icon: Icons.check_rounded,
                      isLoading: state.status == ReceiveStockStatus.saving,
                      onPressed: state.canSubmit ? cubit.submit : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LineCard extends StatefulWidget {
  const _LineCard({
    required this.line,
    required this.onQuantity,
    required this.onUnitCost,
    required this.onRemove,
    super.key,
  });

  final ReceiptLine line;
  final ValueChanged<int> onQuantity;
  final ValueChanged<double?> onUnitCost;
  final VoidCallback onRemove;

  @override
  State<_LineCard> createState() => _LineCardState();
}

class _LineCardState extends State<_LineCard> {
  late final TextEditingController _cost = TextEditingController(
    text: widget.line.unitCost == null
        ? ''
        : MoneyFormatter.amountOnly(widget.line.unitCost!),
  );

  @override
  void dispose() {
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ReceiptLine line = widget.line;
    final String? variant = line.variant?.label;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      line.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong,
                    ),
                    Text(
                      <String>[
                        ?variant,
                        l10n.inventoryStockNow(line.currentStock),
                      ].join(' · '),
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.inventoryRemoveLine,
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              QuantityStepper(
                quantity: line.quantity,
                buttonSize: 38,
                onIncrement: () => widget.onQuantity(line.quantity + 1),
                onDecrement: () => widget.onQuantity(line.quantity - 1),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: TextField(
                    controller: _cost,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (String value) =>
                        widget.onUnitCost(MoneyFormatter.tryParse(value)),
                    decoration: InputDecoration(
                      labelText: l10n.inventoryUnitCostLabel,
                      hintText: MoneyFormatter.amountOnly(
                        line.product.costPrice,
                      ),
                      prefixText: '${MoneyFormatter.currencySymbol} ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

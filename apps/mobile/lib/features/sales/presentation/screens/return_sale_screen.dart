import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';
import '../../domain/usecases/cancel_and_return.dart';
import '../cubit/return_sale_cubit.dart';

/// "Devolver": the units that came back, whether each can be sold again,
/// how the money goes back and why.
class ReturnSaleScreen extends StatefulWidget {
  const ReturnSaleScreen({
    required this.onClose,
    required this.onSaved,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onSaved;

  /// Quick reasons; the seller can also type their own.
  static const List<String> _quickReasons = <String>[
    'Cambio de talla',
    'Producto fallado',
    'No le gustó',
  ];

  @override
  State<ReturnSaleScreen> createState() => _ReturnSaleScreenState();
}

class _ReturnSaleScreenState extends State<ReturnSaleScreen> {
  final TextEditingController _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReturnSaleCubit>().load();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, ReturnSaleState state) {
    final AppLocalizations l10n = context.l10n;
    if (state.status == ReturnSaleStatus.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.returnSaved(
              state.saved!.formattedNumber,
              MoneyFormatter.format(state.saved!.amount),
            ),
          ),
        ),
      );
      widget.onSaved();
      return;
    }
    if (state.failure case final failure?
        when state.status == ReturnSaleStatus.editing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.localizedMessage(l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ReturnSaleCubit cubit = context.read<ReturnSaleCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ReturnSaleCubit, ReturnSaleState>(
          listener: _onState,
          builder: (BuildContext context, ReturnSaleState state) {
            final Sale? sale = state.sale;
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
                    title: l10n.returnTitle,
                    subtitle: sale == null
                        ? null
                        : l10n.salesSaleNumber(sale.formattedNumber),
                    onBack: widget.onClose,
                    isCloseAction: true,
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    ReturnSaleStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    ReturnSaleStatus.failure => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.saleDetailLoadError,
                        message:
                            state.failure?.localizedMessage(l10n) ??
                            l10n.failureUnexpected,
                      ),
                    ),
                    _ => _form(context, cubit, state, sale!),
                  },
                ),
                if (sale != null)
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
                        label: state.units == 0
                            ? l10n.returnSave
                            : l10n.returnSaveAmount(
                                MoneyFormatter.format(state.refund),
                              ),
                        icon: Icons.assignment_return_outlined,
                        isLoading: state.status == ReturnSaleStatus.saving,
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

  Widget _form(
    BuildContext context,
    ReturnSaleCubit cubit,
    ReturnSaleState state,
    Sale sale,
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
              Text(l10n.returnWhatTitle, style: AppTextStyles.bodyLargeStrong),
              if (sale.discount > 0)
                Text(
                  l10n.returnDiscountNote(MoneyFormatter.format(sale.discount)),
                  style: AppTextStyles.captionSmall,
                ),
              for (int i = 0; i < sale.lines.length; i++)
                if (sale.returnableQuantity(i) > 0) ...<Widget>[
                  const Divider(height: AppSpacing.xl),
                  _LineEditor(
                    line: sale.lines[i],
                    returnable: sale.returnableQuantity(i),
                    quantity: state.quantityOf(i),
                    refund: sale.refundFor(i, state.quantityOf(i)),
                    restock: state.restocks(i),
                    onIncrement: () => cubit.increment(i),
                    onDecrement: () => cubit.decrement(i),
                    onRestock: (bool restock) =>
                        cubit.restockChanged(i, restock: restock),
                  ),
                ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.returnRefundTitle,
                style: AppTextStyles.bodyLargeStrong,
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<PaymentMethod>(
                showSelectedIcon: false,
                segments: <ButtonSegment<PaymentMethod>>[
                  for (final PaymentMethod method
                      in SaleCorrectionRules.refundMethodsFor(sale))
                    ButtonSegment<PaymentMethod>(
                      value: method,
                      label: Text(method.localizedName(l10n)),
                    ),
                ],
                selected: <PaymentMethod>{?state.refundMethod},
                onSelectionChanged: (Set<PaymentMethod> selection) =>
                    cubit.refundMethodSelected(selection.single),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.inventoryReasonTitle, style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  for (final String reason in ReturnSaleScreen._quickReasons)
                    ChoiceChip(
                      label: Text(reason),
                      selected: state.reason == reason,
                      onSelected: (_) {
                        _reason.text = reason;
                        cubit.reasonChanged(reason);
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _reason,
                onChanged: cubit.reasonChanged,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: l10n.returnReasonHint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LineEditor extends StatelessWidget {
  const _LineEditor({
    required this.line,
    required this.returnable,
    required this.quantity,
    required this.refund,
    required this.restock,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRestock,
  });

  final SaleLine line;
  final int returnable;
  final int quantity;
  final double refund;
  final bool restock;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<bool> onRestock;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? variant = line.variantLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(line.productName, style: AppTextStyles.bodyStrong),
                  Text(
                    <String>[
                      ?variant,
                      l10n.returnReturnable(returnable),
                    ].join(' · '),
                    style: AppTextStyles.captionSmall,
                  ),
                  if (quantity > 0)
                    Text(
                      l10n.returnLineRefund(MoneyFormatter.format(refund)),
                      style: AppTextStyles.captionSmallStrong.copyWith(
                        color: AppColors.infoText,
                      ),
                    ),
                ],
              ),
            ),
            QuantityStepper(
              quantity: quantity,
              buttonSize: 38,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ],
        ),
        if (quantity > 0)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(l10n.returnRestock, style: AppTextStyles.bodySmall),
                      if (!restock)
                        Text(
                          l10n.returnNoRestock,
                          style: AppTextStyles.captionSmall,
                        ),
                    ],
                  ),
                ),
                Switch(value: restock, onChanged: onRestock),
              ],
            ),
          ),
      ],
    );
  }
}

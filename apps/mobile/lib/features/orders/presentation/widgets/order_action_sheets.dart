import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_requests.dart';
import '../view_data/order_view_data.dart';

/// Money field in bolivianos (`15` or `15,50`).
class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        prefixText: '${MoneyFormatter.currencySymbol} ',
        hintText: '0',
      ),
    );
  }
}

String _amountText(double amount) =>
    amount <= 0 ? '' : MoneyFormatter.amountOnly(amount);

/// Asks the delivery fee when confirming a delivery order.
class DeliveryFeeSheet extends StatefulWidget {
  const DeliveryFeeSheet({required this.initialFee, super.key});

  final double initialFee;

  /// The fee (0 for free delivery), or `null` when dismissed.
  static Future<double?> show(
    BuildContext context, {
    required double initialFee,
  }) {
    final AppLocalizations l10n = context.l10n;
    return AppBottomSheet.show<double>(
      context: context,
      title: l10n.orderDeliveryFeeTitle,
      subtitle: l10n.orderDeliveryFeeSubtitle,
      builder: (_) => DeliveryFeeSheet(initialFee: initialFee),
    );
  }

  @override
  State<DeliveryFeeSheet> createState() => _DeliveryFeeSheetState();
}

class _DeliveryFeeSheetState extends State<DeliveryFeeSheet> {
  late final TextEditingController _fee = TextEditingController(
    text: _amountText(widget.initialFee),
  );

  @override
  void dispose() {
    _fee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LabeledField(
            label: l10n.receiptDeliveryLabel,
            child: _AmountField(controller: _fee),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: l10n.orderActionConfirm,
            icon: Icons.check_rounded,
            onPressed: () =>
                Navigator.of(context)
                    .pop<double>(MoneyFormatter.tryParse(_fee.text) ?? 0),
          ),
        ],
      ),
    );
  }
}

/// Asks why the order is cancelled; returns the reason, or `null`.
class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog({required this.order, super.key});

  final Order order;

  static Future<String?> show(BuildContext context, {required Order order}) =>
      showDialog<String>(
        context: context,
        builder: (_) => CancelOrderDialog(order: order),
      );

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final TextEditingController _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<String> quickReasons = <String>[
      l10n.orderCancelReasonNoStock,
      l10n.orderCancelReasonNoAnswer,
      l10n.orderCancelReasonCustomer,
    ];

    return AlertDialog(
      title: Text(l10n.orderCancelTitle(widget.order.formattedNumber)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l10n.orderCancelMessage),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final String reason in quickReasons)
                  ChoiceChip(
                    label: Text(reason),
                    selected: _reason.text == reason,
                    onSelected: (_) => setState(() => _reason.text = reason),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _reason,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: l10n.returnReasonHint),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonBack),
        ),
        TextButton(
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_reason.text.trim()),
          style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
          child: Text(l10n.orderActionCancel),
        ),
      ],
    );
  }
}

/// Changes quantities, removes lines and sets the delivery fee
/// (`ECO-R10`).
class EditOrderSheet extends StatefulWidget {
  const EditOrderSheet({required this.order, super.key});

  final Order order;

  static Future<OrderEdit?> show(BuildContext context, {required Order order}) {
    final AppLocalizations l10n = context.l10n;
    return AppBottomSheet.show<OrderEdit>(
      context: context,
      title: l10n.orderEditTitle(order.formattedNumber),
      builder: (_) => EditOrderSheet(order: order),
    );
  }

  @override
  State<EditOrderSheet> createState() => _EditOrderSheetState();
}

class _EditOrderSheetState extends State<EditOrderSheet> {
  late final List<int> _quantities = <int>[
    for (final OrderLine line in widget.order.lines) line.quantity,
  ];
  late final TextEditingController _fee = TextEditingController(
    text: _amountText(widget.order.deliveryFee),
  );

  /// Lines and fee as typed now.
  OrderEdit get _edit => OrderEdit(
    quantities: List<int>.of(_quantities),
    deliveryFee: widget.order.isDelivery
        ? MoneyFormatter.tryParse(_fee.text) ?? 0
        : 0,
  );

  double get _total {
    double total = _edit.deliveryFee;
    for (int i = 0; i < widget.order.lines.length; i++) {
      total += widget.order.lines[i].unitPrice * _quantities[i];
    }
    return total;
  }

  @override
  void dispose() {
    _fee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool empty = _quantities.every((int quantity) => quantity == 0);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                for (int i = 0; i < widget.order.lines.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                OrderTexts.itemName(
                                  l10n,
                                  widget.order.lines[i],
                                ),
                                style: AppTextStyles.bodySmallStrong.copyWith(
                                  decoration: _quantities[i] == 0
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              Text(
                                MoneyFormatter.format(
                                  widget.order.lines[i].unitPrice,
                                ),
                                style: AppTextStyles.captionSmall,
                              ),
                            ],
                          ),
                        ),
                        QuantityStepper(
                          quantity: _quantities[i],
                          buttonSize: 38,
                          onIncrement: () => setState(() => _quantities[i]++),
                          onDecrement: () => setState(() {
                            if (_quantities[i] > 0) _quantities[i]--;
                          }),
                        ),
                      ],
                    ),
                  ),
                if (widget.order.isDelivery)
                  LabeledField(
                    label: l10n.receiptDeliveryLabel,
                    child: _AmountField(
                      controller: _fee,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: l10n.orderEditSave(MoneyFormatter.format(_total)),
            icon: Icons.check_rounded,
            onPressed: empty
                ? null
                : () => Navigator.of(context).pop<OrderEdit>(_edit),
          ),
        ],
      ),
    );
  }
}

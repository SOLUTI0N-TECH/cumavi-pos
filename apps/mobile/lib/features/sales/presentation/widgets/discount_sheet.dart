import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';

/// Asks for a discount in bolivianos for the whole sale.
class DiscountSheet extends StatefulWidget {
  const DiscountSheet({required this.currentDiscount, super.key});

  final double currentDiscount;

  /// Returns the new discount, or `null` when dismissed.
  static Future<double?> show(
    BuildContext context, {
    required double currentDiscount,
  }) {
    final AppLocalizations l10n = context.l10n;
    return AppBottomSheet.show<double>(
      context: context,
      title: l10n.salesDiscountSheetTitle,
      subtitle: l10n.salesDiscountSheetSubtitle,
      builder: (_) => DiscountSheet(currentDiscount: currentDiscount),
    );
  }

  @override
  State<DiscountSheet> createState() => _DiscountSheetState();
}

class _DiscountSheetState extends State<DiscountSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentDiscount > 0
        ? MoneyFormatter.amountOnly(widget.currentDiscount)
        : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LabeledField(
          label: l10n.salesDiscountSheetAmountLabel,
          child: AmountInputField(controller: _controller, autofocus: true),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: l10n.salesDiscountSheetApplyButton,
          onPressed: () =>
              Navigator.of(context)
                  .pop(MoneyFormatter.tryParse(_controller.text) ?? 0),
        ),
      ],
    );
  }
}

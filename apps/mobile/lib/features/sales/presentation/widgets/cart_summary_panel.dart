import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/cart.dart';

/// Floating panel above the navigation bar with the subtotal, the discount
/// shortcut and the charge button.
class CartSummaryPanel extends StatelessWidget {
  const CartSummaryPanel({
    required this.cart,
    required this.onCharge,
    required this.onAddDiscount,
    super.key,
  });

  final Cart cart;
  final VoidCallback? onCharge;
  final VoidCallback onAddDiscount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isEnabled = cart.isNotEmpty && onCharge != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14292526),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: cart.isEmpty
                        ? l10n.salesSummaryTotalItems(
                            l10n.itemCount(cart.itemCount),
                          )
                        : l10n.salesSummarySubtotalLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: <InlineSpan>[
                      if (cart.isNotEmpty)
                        TextSpan(
                          text: MoneyFormatter.format(cart.subtotal),
                          style: AppTextStyles.bodySmallStrong,
                        ),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: cart.isEmpty ? null : onAddDiscount,
                icon: const Icon(Icons.percent_rounded, size: 16),
                label: Text(
                  cart.discount > 0
                      ? '− ${MoneyFormatter.format(cart.discount)}'
                      : l10n.salesSummaryDiscountButton,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          FilledButton(
            onPressed: isEnabled ? onCharge : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(l10n.salesSummaryChargeButton)),
                Text(
                  MoneyFormatter.format(cart.total),
                  style: AppTextStyles.amountSm.copyWith(
                    fontSize: 22,
                    color: isEnabled
                        ? AppColors.white
                        : AppColors.textPlaceholder,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

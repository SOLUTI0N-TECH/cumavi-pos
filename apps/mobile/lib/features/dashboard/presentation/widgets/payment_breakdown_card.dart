import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../sales/domain/entities/daily_sales_summary.dart';
import '../../../sales/presentation/view_data/payment_method_view_data.dart';

/// Today's revenue split by payment method: one stacked bar plus a legend.
class PaymentBreakdownCard extends StatelessWidget {
  const PaymentBreakdownCard({required this.summary, super.key});

  final DailySalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final List<PaymentMethod> methods = summary.usedMethods;
    final AppLocalizations l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.dashboardPaymentBreakdownTitle,
                  style: AppTextStyles.bodyLargeStrong,
                ),
              ),
              Text(
                l10n.dashboardPaymentBreakdownPeriod,
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          if (methods.isEmpty)
            Text(
              l10n.dashboardPaymentBreakdownEmpty,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else ...<Widget>[
            Row(
              children: <Widget>[
                for (final PaymentMethod method in methods) ...<Widget>[
                  Expanded(
                    flex: math.max(
                      1,
                      (summary.shareFor(method) * 1000).round(),
                    ),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: method.chartColor,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  if (method != methods.last)
                    const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md + 2),
            for (final PaymentMethod method in methods)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                child: _LegendRow(
                  method: method,
                  share: summary.shareFor(method),
                  amount: summary.totalFor(method),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.method,
    required this.share,
    required this.amount,
  });

  final PaymentMethod method;
  final double share;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: method.chartColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Text(
            method.localizedName(context.l10n),
            style: AppTextStyles.bodySmall,
          ),
        ),
        Text(
          MoneyFormatter.formatPercent(share, decimals: 0),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          MoneyFormatter.format(amount),
          style: AppTextStyles.bodySmallStrong,
        ),
      ],
    );
  }
}

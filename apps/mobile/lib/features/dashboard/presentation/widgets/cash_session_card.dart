import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/dashboard_snapshot.dart';

/// Charcoal hero card: cash drawer state, today's revenue and the shortcut to
/// start selling.
class CashSessionCard extends StatelessWidget {
  const CashSessionCard({
    required this.snapshot,
    required this.onStartSale,
    required this.onOpenHistory,
    super.key,
  });

  final DashboardSnapshot snapshot;
  final VoidCallback onStartSale;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final bool isOpen = snapshot.isCashSessionOpen;
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.xxxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _DrawerStatePill(snapshot: snapshot),
                ),
              ),
              Text(
                l10n.dashboardCashCardNoShifts,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.dashboardCashCardTodaySales,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.72),
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenHistory,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      l10n.dashboardCashCardHistory,
                      style: AppTextStyles.captionSmallStrong.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text.rich(
            TextSpan(
              text: '${MoneyFormatter.currencySymbol} ',
              style: AppTextStyles.amountMd.copyWith(
                fontSize: 22,
                color: AppColors.white.withValues(alpha: 0.72),
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: MoneyFormatter.amountOnly(snapshot.sales.total),
                  style: AppTextStyles.amountXl.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                _Metric(
                  value: '${snapshot.sales.saleCount}',
                  label: l10n.dashboardCashCardSalesMetric,
                ),
                _Metric(
                  value: MoneyFormatter.format(snapshot.sales.averageTicket),
                  label: l10n.dashboardCashCardAverageTicketMetric,
                  hasDivider: true,
                ),
                _Metric(
                  value: MoneyFormatter.formatCompact(snapshot.cashInDrawer),
                  label: l10n.dashboardCashCardCashInDrawerMetric,
                  hasDivider: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: onStartSale,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(54),
              textStyle: AppTextStyles.bodyLargeStrong.copyWith(fontSize: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg + 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  isOpen ? Icons.add_rounded : Icons.lock_open_rounded,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  isOpen
                      ? l10n.dashboardCashCardNewSale
                      : l10n.dashboardCashCardOpenCashRegister,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerStatePill extends StatelessWidget {
  const _DrawerStatePill({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final bool isOpen = snapshot.isCashSessionOpen;
    final AppLocalizations l10n = context.l10n;
    final String label = isOpen
        ? l10n.dashboardCashCardOpenSince(
            DateFormatter.time(snapshot.cashSession!.openedAt),
          )
        : l10n.dashboardCashCardClosed;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.success : AppColors.textOnDarkMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.captionSmallStrong.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    this.hasDivider = false,
  });

  final String value;
  final String label;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: hasDivider ? AppSpacing.md : 0),
        decoration: hasDivider
            ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppColors.white.withValues(alpha: 0.12),
                  ),
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTextStyles.bodyLargeStrong.copyWith(
                  fontSize: 20,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

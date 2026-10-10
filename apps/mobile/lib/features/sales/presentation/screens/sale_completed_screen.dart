import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/dashed_divider.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';
import '../view_data/payment_method_view_data.dart';
import '../widgets/print_receipt_sheet.dart';
import '../widgets/share_receipt_sheet.dart';

/// Confirmation after charging: what was sold and what to do next.
class SaleCompletedScreen extends StatelessWidget {
  const SaleCompletedScreen({
    required this.sale,
    required this.onNewSale,
    required this.onGoHome,
    required this.onOpenReceipt,
    this.primaryLabel,
    super.key,
  });

  final Sale sale;

  /// The main button; "Nueva venta" unless [primaryLabel] says otherwise.
  final VoidCallback onNewSale;
  final String? primaryLabel;
  final VoidCallback onGoHome;
  final VoidCallback onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxxl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: <Widget>[
                  const _SuccessMark(),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.salesCompletedTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.salesCompletedSubtitle(
                      sale.formattedNumber,
                      DateFormatter.shortDate(sale.createdAt),
                      DateFormatter.time(sale.createdAt),
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _SaleDetailCard(sale: sale),
                  const SizedBox(height: AppSpacing.lg),
                  _ActionRow(sale: sale, onOpenReceipt: onOpenReceipt),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                0,
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
              ),
              child: Column(
                children: <Widget>[
                  PrimaryButton(
                    label: primaryLabel ?? l10n.salesCompletedNewSaleButton,
                    icon: primaryLabel == null
                        ? Icons.add_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: onNewSale,
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onGoHome,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.inkSoft,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l10n.salesCompletedGoHomeButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 84,
        width: 84,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(color: AppColors.successRing, spreadRadius: 10),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.white,
          size: 42,
        ),
      ),
    );
  }
}

class _SaleDetailCard extends StatelessWidget {
  const _SaleDetailCard({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.salesCompletedDetailTitle,
                  style: AppTextStyles.bodyLargeStrong.copyWith(fontSize: 17),
                ),
              ),
              StatusPill(
                label: sale.paymentMethod.localizedName(l10n),
                icon: sale.paymentMethod.icon,
                background: sale.paymentMethod.tintSurface,
                foreground: sale.paymentMethod.tintColor,
                height: 28,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final SaleLine line in sale.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
              child: _SoldLine(line: line),
            ),
          const SizedBox(height: AppSpacing.sm),
          const DashedDivider(),
          const SizedBox(height: AppSpacing.lg),
          KeyValueRow(
            label: l10n.salesCompletedTotalLabel,
            value: MoneyFormatter.format(sale.total),
            emphasize: true,
            valueStyle: AppTextStyles.amountMd,
          ),
          const SizedBox(height: AppSpacing.sm),
          KeyValueRow(
            label: l10n.salesCompletedReceivedLabel,
            value: MoneyFormatter.format(sale.amountReceived),
          ),
          if (sale.change > 0) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            KeyValueRow(
              label: l10n.salesCompletedChangeLabel,
              value: MoneyFormatter.format(sale.change),
              valueStyle: AppTextStyles.bodySmallStrong.copyWith(
                color: AppColors.successTextStrong,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `2×  Zapatillas urbanas  Bs 900,00`, with the variant under the name.
class _SoldLine extends StatelessWidget {
  const _SoldLine({required this.line});

  final SaleLine line;

  @override
  Widget build(BuildContext context) {
    final String? variantLabel = line.variantLabel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 28,
          child: Text(
            '${line.quantity}×',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                line.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
              if (variantLabel != null)
                Text(
                  variantLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.captionSmall,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          MoneyFormatter.format(line.total),
          style: AppTextStyles.bodySmallStrong,
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.sale, required this.onOpenReceipt});

  final Sale sale;
  final VoidCallback onOpenReceipt;

  Receipt _receiptOf(BuildContext context) => Receipt(
    sale: sale,
    business: context.read<SessionCubit>().state.business,
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Row(
      children: <Widget>[
        _ActionTile(
          icon: Icons.receipt_long_outlined,
          label: l10n.salesReceiptActionView,
          onTap: onOpenReceipt,
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        _ActionTile(
          icon: Icons.print_outlined,
          label: l10n.salesReceiptActionPrint,
          onTap: () =>
              PrintReceiptSheet.show(context, receipt: _receiptOf(context)),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        _ActionTile(
          icon: Icons.share_outlined,
          label: l10n.salesReceiptActionShare,
          onTap: () =>
              ShareReceiptSheet.show(context, receipt: _receiptOf(context)),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTextStyles.bodySmallStrong,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

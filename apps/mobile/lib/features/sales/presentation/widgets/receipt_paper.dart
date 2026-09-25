import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/dashed_divider.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../auth/domain/entities/business_profile.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';

/// Printed-receipt layout: store header, items, totals and payment.
///
/// The same widget renders the on-screen receipt and the thermal print
/// preview, so what the customer gets always matches what the seller sees.
class ReceiptPaper extends StatelessWidget {
  const ReceiptPaper({required this.sale, required this.business, super.key});

  final Sale sale;
  final BusinessProfile? business;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
              bottom: Radius.circular(4),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x14292526),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _StoreHeader(business: business),
              const SizedBox(height: AppSpacing.md + 2),
              const DashedDivider(),
              const SizedBox(height: AppSpacing.md + 2),
              _ReceiptMeta(sale: sale),
              const SizedBox(height: AppSpacing.md + 2),
              const DashedDivider(),
              const SizedBox(height: AppSpacing.md + 2),
              for (final SaleLine line in sale.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
                  child: _ReceiptLine(line: line),
                ),
              const SizedBox(height: AppSpacing.xs),
              const DashedDivider(),
              const SizedBox(height: AppSpacing.md + 2),
              _ReceiptTotals(sale: sale),
              const SizedBox(height: AppSpacing.md + 2),
              const DashedDivider(),
              const SizedBox(height: AppSpacing.md + 2),
              Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      l10n.receiptThanks,
                      style: AppTextStyles.bodySmallStrong,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          l10n.receiptMadeWithPrefix,
                          style: AppTextStyles.micro,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        const BrandMark(size: 18, showWordmark: false),
                        const SizedBox(width: AppSpacing.xs),
                        Text(l10n.appTitle, style: AppTextStyles.micro),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 4,
          right: 4,
          bottom: -8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(
              12,
              (_) => Container(
                height: 16,
                width: 16,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.business});

  final BusinessProfile? business;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? department = business?.department.displayName;
    final String location = department == null
        ? l10n.receiptCountry
        : l10n.salesReceiptStoreLocation(department, l10n.receiptCountry);
    final String? taxId = business?.taxId;

    return Column(
      children: <Widget>[
        BusinessAvatar(initials: business?.initials ?? 'C'),
        const SizedBox(height: AppSpacing.sm + 2),
        Text(
          business?.name ?? l10n.commonDefaultBusinessName,
          style: AppTextStyles.bodyLargeStrong,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          taxId == null
              ? location
              : l10n.salesReceiptStoreDetails(
                  location,
                  l10n.receiptTaxId(taxId),
                ),
          style: AppTextStyles.captionSmall,
        ),
      ],
    );
  }
}

class _ReceiptMeta extends StatelessWidget {
  const _ReceiptMeta({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Column(
      children: <Widget>[
        KeyValueRow(
          label: l10n.receiptNumberLabel,
          value: sale.formattedNumber.replaceAll('#', ''),
          valueStyle: AppTextStyles.captionSmallStrong.copyWith(
            color: AppColors.textPrimary,
          ),
          labelStyle: AppTextStyles.caption,
        ),
        const SizedBox(height: 6),
        KeyValueRow(
          label: l10n.receiptDateLabel,
          value: DateFormatter.receiptStamp(sale.createdAt),
          valueStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
          ),
          labelStyle: AppTextStyles.caption,
        ),
        const SizedBox(height: 6),
        KeyValueRow(
          label: l10n.receiptCashierLabel,
          value: sale.cashierName,
          valueStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
          ),
          labelStyle: AppTextStyles.caption,
        ),
      ],
    );
  }
}

/// Product, its variant (`Azul · 40`) when it has one, units and total.
class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({required this.line});

  final SaleLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(line.productName, style: AppTextStyles.bodySmall),
              if (line.variantLabel case final String variantLabel)
                Text(
                  variantLabel,
                  style: AppTextStyles.captionSmallStrong.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
              Text(
                '${line.quantity} × ${MoneyFormatter.format(line.unitPrice)}',
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          MoneyFormatter.format(line.total),
          style: AppTextStyles.bodySmallStrong,
        ),
      ],
    );
  }
}

class _ReceiptTotals extends StatelessWidget {
  const _ReceiptTotals({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (sale.discount > 0) ...<Widget>[
          KeyValueRow(
            label: l10n.receiptSubtotalLabel,
            value: MoneyFormatter.format(sale.subtotal),
          ),
          const SizedBox(height: 6),
          KeyValueRow(
            label: l10n.receiptDiscountLabel,
            value: '− ${MoneyFormatter.format(sale.discount)}',
          ),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.receiptTotalLabel,
                style: AppTextStyles.bodyStrong.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Text(
              MoneyFormatter.format(sale.total),
              style: AppTextStyles.amountMd,
            ),
          ],
        ),
        const SizedBox(height: 6),
        KeyValueRow(
          label: sale.paymentMethod.localizedName(l10n),
          value: MoneyFormatter.format(sale.amountReceived),
        ),
        if (sale.change > 0) ...<Widget>[
          const SizedBox(height: 6),
          KeyValueRow(
            label: l10n.receiptChangeLabel,
            value: MoneyFormatter.format(sale.change),
          ),
        ],
      ],
    );
  }
}

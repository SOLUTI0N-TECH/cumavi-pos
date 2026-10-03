import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../domain/entities/receipt.dart';
import '../widgets/print_receipt_sheet.dart';
import '../widgets/receipt_paper.dart';
import '../widgets/share_receipt_sheet.dart';

/// Full receipt of a sale, with the print and share actions.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({required this.receipt, required this.onBack, super.key});

  /// Its business is taken from the session.
  final Receipt receipt;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final Receipt receipt = this.receipt.withBusiness(
      context.watch<SessionCubit>().state.business,
    );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: PushedScreenHeader(
                title: receipt.isRefund
                    ? context.l10n.salesRefundReceiptTitle
                    : context.l10n.salesReceiptScreenTitle,
                subtitle: receipt.isRefund
                    ? receipt.referenceLabel(context.l10n)
                    : context.l10n.salesSaleNumber(
                        receipt.sale.formattedNumber,
                      ),
                onBack: onBack,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.xxxl,
                ),
                children: <Widget>[ReceiptPaper(receipt: receipt)],
              ),
            ),
            _ReceiptActions(receipt: receipt),
          ],
        ),
      ),
    );
  }
}

class _ReceiptActions extends StatelessWidget {
  const _ReceiptActions({required this.receipt});

  final Receipt receipt;

  Receipt _receiptOf(BuildContext context) => receipt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SecondaryButton(
              label: l10n.salesReceiptActionPrint,
              icon: Icons.print_outlined,
              onPressed: () =>
                  PrintReceiptSheet.show(context, receipt: _receiptOf(context)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: FilledButton.icon(
              onPressed: () =>
                  ShareReceiptSheet.show(context, receipt: _receiptOf(context)),
              icon: const Icon(Icons.share_outlined, size: 20),
              label: Text(l10n.salesReceiptActionShare),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(58),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

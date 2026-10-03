import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';
import '../../domain/entities/sale_return.dart';
import '../cubit/sale_detail_cubit.dart';

/// A past sale: what was sold, the payment and who sold it, with its
/// receipt one tap away (to view, print or share it again). While allowed,
/// the sale can be cancelled ("Anular") or some units returned.
class SaleDetailScreen extends StatefulWidget {
  const SaleDetailScreen({
    required this.onBack,
    required this.onOpenReceipt,
    required this.onReturn,
    super.key,
  });

  final VoidCallback onBack;

  /// The sale's receipt, or one of its returns'.
  final ValueChanged<Receipt> onOpenReceipt;

  /// Opens "Devolver"; completes when the seller comes back.
  final Future<void> Function() onReturn;

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SaleDetailCubit>().load();
  }

  Future<void> _return() async {
    await widget.onReturn();
    if (mounted) await context.read<SaleDetailCubit>().load();
  }

  Future<void> _cancel(Sale sale) async {
    final AppLocalizations l10n = context.l10n;
    final SaleDetailCubit cubit = context.read<SaleDetailCubit>();
    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) => _CancelDialog(sale: sale),
    );
    if (reason == null || !mounted) return;
    final Failure? failure = await cubit.cancel(reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failure?.localizedMessage(l10n) ?? l10n.saleDetailCancelled,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SaleDetailCubit, SaleDetailState>(
          builder: (BuildContext context, SaleDetailState state) {
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
                    title: sale == null
                        ? l10n.saleDetailTitleLoading
                        : l10n.saleDetailTitle(sale.formattedNumber),
                    subtitle: sale == null
                        ? null
                        : '${DateFormatter.longDate(sale.createdAt)} · '
                              '${DateFormatter.time(sale.createdAt)}',
                    onBack: widget.onBack,
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    SaleDetailStatus.loading when sale == null => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    SaleDetailStatus.failure when sale == null => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.saleDetailLoadError,
                        message:
                            state.failure?.localizedMessage(l10n) ??
                            l10n.failureUnexpected,
                        action: OutlinedButton(
                          onPressed: context.read<SaleDetailCubit>().load,
                          child: Text(l10n.commonRetry),
                        ),
                      ),
                    ),
                    _ => _SaleDetails(
                      sale: sale!,
                      onOpenReturnReceipt: (SaleReturn refund) =>
                          widget.onOpenReceipt(
                            Receipt.refund(original: sale, refund: refund),
                          ),
                    ),
                  },
                ),
                if (sale != null)
                  _Footer(
                    state: state,
                    onCancel: () => _cancel(sale),
                    onReturn: _return,
                    onOpenReceipt: () =>
                        widget.onOpenReceipt(Receipt(sale: sale)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SaleDetails extends StatelessWidget {
  const _SaleDetails({required this.sale, required this.onOpenReturnReceipt});

  final Sale sale;
  final ValueChanged<SaleReturn> onOpenReturnReceipt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isCash = sale.paymentMethod == PaymentMethod.cash;
    final SaleCancellation? cancellation = sale.cancellation;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        if (cancellation != null) ...<Widget>[
          _Card(
            title: l10n.saleDetailCancelledTitle,
            trailing: _StatusPill(status: sale.status),
            children: <Widget>[
              Text(cancellation.reason, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.inventoryMovementWhen(
                  DateFormatter.shortDateTime(cancellation.cancelledAt),
                  cancellation.cancelledBy,
                ),
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _Card(
          title: l10n.saleDetailProducts(sale.itemCount),
          trailing: cancellation == null && sale.status != SaleStatus.completed
              ? _StatusPill(status: sale.status)
              : null,
          children: <Widget>[
            for (int i = 0; i < sale.lines.length; i++) ...<Widget>[
              if (i > 0) const Divider(height: AppSpacing.xl),
              _LineRow(line: sale.lines[i], returned: sale.returnedQuantity(i)),
            ],
            const Divider(height: AppSpacing.xxl),
            KeyValueRow(
              label: l10n.saleDetailSubtotal,
              value: MoneyFormatter.format(sale.subtotal),
            ),
            if (sale.discount > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              KeyValueRow(
                label: l10n.saleDetailDiscount,
                value: '− ${MoneyFormatter.format(sale.discount)}',
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            KeyValueRow(
              label: l10n.saleDetailTotal,
              value: MoneyFormatter.format(sale.total),
              emphasize: true,
            ),
            if (sale.refundedTotal > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              KeyValueRow(
                label: l10n.saleDetailRefunded,
                value: '− ${MoneyFormatter.format(sale.refundedTotal)}',
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.saleDetailPayment,
          children: <Widget>[
            KeyValueRow(
              label: l10n.saleDetailMethod,
              value: sale.paymentMethod.localizedName(l10n),
            ),
            if (isCash) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              KeyValueRow(
                label: l10n.saleDetailReceived,
                value: MoneyFormatter.format(sale.amountReceived),
              ),
              const SizedBox(height: AppSpacing.sm),
              KeyValueRow(
                label: l10n.saleDetailChange,
                value: MoneyFormatter.format(sale.change),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            KeyValueRow(label: l10n.saleDetailCashier, value: sale.cashierName),
          ],
        ),
        if (sale.returns.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _Card(
            title: l10n.saleDetailReturnsTitle,
            children: <Widget>[
              for (int i = 0; i < sale.returns.length; i++) ...<Widget>[
                if (i > 0) const Divider(height: AppSpacing.xl),
                _ReturnRow(
                  refund: sale.returns[i],
                  onOpenReceipt: () => onOpenReturnReceipt(sale.returns[i]),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool cancelled = status == SaleStatus.cancelled;
    return StatusPill(
      label: switch (status) {
        SaleStatus.completed => '',
        SaleStatus.cancelled => l10n.saleStatusCancelled,
        SaleStatus.partiallyReturned => l10n.saleStatusPartiallyReturned,
        SaleStatus.returned => l10n.saleStatusReturned,
      },
      background: cancelled ? AppColors.errorSurface : AppColors.infoSurface,
      foreground: cancelled ? AppColors.errorText : AppColors.infoText,
      height: 28,
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children, this.trailing});

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(title, style: AppTextStyles.bodyLargeStrong),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.returned});

  final SaleLine line;

  /// Units of this line already returned.
  final int returned;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? variant = line.variantLabel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(line.productName, style: AppTextStyles.bodyStrong),
              if (variant != null)
                Text(variant, style: AppTextStyles.captionSmall),
              const SizedBox(height: 2),
              Text(
                l10n.saleDetailUnitPrice(
                  line.quantity,
                  MoneyFormatter.format(line.unitPrice),
                ),
                style: AppTextStyles.captionSmall,
              ),
              if (returned > 0)
                Text(
                  l10n.saleDetailReturnedUnits(returned),
                  style: AppTextStyles.captionSmallStrong.copyWith(
                    color: AppColors.infoText,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          MoneyFormatter.format(line.total),
          style: AppTextStyles.bodyStrong,
        ),
      ],
    );
  }
}

class _ReturnRow extends StatelessWidget {
  const _ReturnRow({required this.refund, required this.onOpenReceipt});

  final SaleReturn refund;
  final VoidCallback onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.saleDetailReturnSummary(
                  refund.formattedNumber,
                  refund.units,
                ),
                style: AppTextStyles.bodyStrong,
              ),
              Text(
                '${refund.reason} · '
                '${refund.refundMethod.localizedName(l10n)}',
                style: AppTextStyles.captionSmall,
              ),
              Text(
                l10n.inventoryMovementWhen(
                  DateFormatter.shortDateTime(refund.createdAt),
                  refund.cashierName,
                ),
                style: AppTextStyles.captionSmall,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onOpenReceipt,
                child: Text(l10n.saleDetailViewReceipt),
              ),
            ],
          ),
        ),
        Text(
          '− ${MoneyFormatter.format(refund.amount)}',
          style: AppTextStyles.bodyStrong,
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.state,
    required this.onCancel,
    required this.onReturn,
    required this.onOpenReceipt,
  });

  final SaleDetailState state;
  final VoidCallback onCancel;
  final VoidCallback onReturn;
  final VoidCallback onOpenReceipt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool busy = state.cancelling;

    return DecoratedBox(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (state.canCancel || state.canReturn) ...<Widget>[
              Row(
                children: <Widget>[
                  if (state.canCancel)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorText,
                        ),
                        icon: const Icon(Icons.block_rounded, size: 18),
                        label: Text(l10n.saleDetailCancel),
                      ),
                    ),
                  if (state.canCancel && state.canReturn)
                    const SizedBox(width: AppSpacing.sm),
                  if (state.canReturn)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : onReturn,
                        icon: const Icon(
                          Icons.assignment_return_outlined,
                          size: 18,
                        ),
                        label: Text(l10n.saleDetailReturn),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            PrimaryButton(
              label: l10n.saleDetailViewReceipt,
              icon: Icons.receipt_long_rounded,
              onPressed: onOpenReceipt,
            ),
          ],
        ),
      ),
    );
  }
}

/// Asks why the sale is cancelled; returns the reason, or `null`.
class _CancelDialog extends StatefulWidget {
  const _CancelDialog({required this.sale});

  final Sale sale;

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final TextEditingController _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.saleDetailCancelTitle(widget.sale.formattedNumber)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.saleDetailCancelMessage(
              MoneyFormatter.format(widget.sale.total),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _reason,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: l10n.saleDetailReasonHint),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: _reason.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_reason.text.trim()),
          style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
          child: Text(l10n.saleDetailCancel),
        ),
      ],
    );
  }
}

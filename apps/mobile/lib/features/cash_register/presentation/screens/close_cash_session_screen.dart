import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/tinted_banner.dart';
import '../../domain/entities/cash_close_summary.dart';
import '../cubit/cash_close_cubit.dart';
import '../cubit/cash_close_state.dart';

/// Close-drawer screen: what the day produced, what should be in the drawer
/// and what the cashier actually counted.
class CloseCashSessionScreen extends StatefulWidget {
  const CloseCashSessionScreen({
    required this.onClosed,
    required this.onBack,
    required this.onOpenSales,
    super.key,
  });

  /// Called once the drawer is closed, so the shell can refresh and go back
  /// to the opening form.
  final VoidCallback onClosed;
  final VoidCallback onBack;

  /// The day's sales in the history, to check one before closing.
  final VoidCallback onOpenSales;

  @override
  State<CloseCashSessionScreen> createState() => _CloseCashSessionScreenState();
}

class _CloseCashSessionScreenState extends State<CloseCashSessionScreen> {
  final TextEditingController _countedController = TextEditingController();
  bool _didPrefillCountedAmount = false;

  @override
  void initState() {
    super.initState();
    context.read<CashCloseCubit>().load();
  }

  @override
  void dispose() {
    _countedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CashCloseCubit, CashCloseState>(
          listener: (BuildContext context, CashCloseState state) {
            if (state.status == CashCloseStatus.ready &&
                !_didPrefillCountedAmount &&
                state.countedAmount != null) {
              _didPrefillCountedAmount = true;
              _countedController.text = MoneyFormatter.amountOnly(
                state.countedAmount!,
              );
            }
            if (state.status == CashCloseStatus.closed) {
              widget.onClosed();
            }
            if (state.status == CashCloseStatus.failure &&
                state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure!.localizedMessage(context.l10n)),
                ),
              );
            }
          },
          builder: (BuildContext context, CashCloseState state) {
            final AppLocalizations l10n = context.l10n;
            final CashCloseSummary? summary = state.summary;
            if (summary == null) {
              return state.status == CashCloseStatus.failure
                  ? _CloseError(
                      message:
                          state.failure?.localizedMessage(l10n) ??
                          l10n.cashRegisterCloseLoadFailed,
                      onBack: widget.onBack,
                    )
                  : const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: PushedScreenHeader(
                    title: l10n.cashRegisterCloseTitle,
                    subtitle: l10n.cashRegisterCloseSubtitle(
                      DateFormatter.time(summary.session.openedAt),
                    ),
                    onBack: widget.onBack,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                      AppSpacing.pageHorizontal,
                      AppSpacing.xxl,
                    ),
                    children: <Widget>[
                      _SessionSummaryCard(summary: summary),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: widget.onOpenSales,
                          icon: const Icon(
                            Icons.receipt_long_outlined,
                            size: 18,
                          ),
                          label: Text(l10n.cashRegisterViewSales),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _ExpectedCashCard(summary: summary),
                      const SizedBox(height: AppSpacing.xl),
                      LabeledField(
                        label: l10n.cashRegisterCountedCashLabel,
                        child: AmountInputField(
                          controller: _countedController,
                          height: 64,
                          fontSize: 30,
                          onChanged: (String value) => context
                              .read<CashCloseCubit>()
                              .countedAmountChanged(
                                MoneyFormatter.tryParse(value),
                              ),
                        ),
                      ),
                      if (state.hasDifference) ...<Widget>[
                        const SizedBox(height: AppSpacing.lg),
                        _DifferenceBanner(difference: state.difference!),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      LabeledField(
                        label: l10n.cashRegisterNoteLabel,
                        child: TextField(
                          minLines: 2,
                          maxLines: 3,
                          onChanged: context.read<CashCloseCubit>().noteChanged,
                          decoration: InputDecoration(
                            hintText: l10n.cashRegisterNoteHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    0,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xxl,
                  ),
                  child: PrimaryButton(
                    label: l10n.cashRegisterConfirmClose,
                    icon: Icons.lock_outline_rounded,
                    isLoading: state.status == CashCloseStatus.submitting,
                    onPressed: state.canSubmit
                        ? context.read<CashCloseCubit>().submit
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({required this.summary});

  final CashCloseSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          KeyValueRow(
            label: l10n.cashRegisterOpeningAmount,
            value: MoneyFormatter.format(summary.session.openingAmount),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          for (final PaymentMethod method in summary.sales.usedMethods)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
              child: KeyValueRow(
                label: l10n.cashRegisterSalesByMethod(
                  method.localizedName(l10n).toLowerCase(),
                ),
                value: MoneyFormatter.format(summary.sales.totalFor(method)),
              ),
            ),
          // Refunds are already out of the method totals above.
          if (summary.sales.refundCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
              child: KeyValueRow(
                label: l10n.cashRegisterRefunds(summary.sales.refundCount),
                value: '− ${MoneyFormatter.format(summary.sales.refundTotal)}',
              ),
            ),
          const Divider(height: AppSpacing.xxl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: l10n.cashRegisterTotalSold,
                    style: AppTextStyles.bodyStrong,
                    children: <InlineSpan>[
                      TextSpan(
                        text: l10n.cashRegisterSaleCount(
                          summary.sales.saleCount,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                MoneyFormatter.format(summary.sales.total),
                style: AppTextStyles.amountSm.copyWith(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpectedCashCard extends StatelessWidget {
  const _ExpectedCashCard({required this.summary});

  final CashCloseSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.xxl - 2),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.cashRegisterExpectedCash,
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  context.l10n.cashRegisterExpectedCashFormula,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          Text(
            MoneyFormatter.format(summary.expectedCash),
            style: AppTextStyles.amountMd.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _DifferenceBanner extends StatelessWidget {
  const _DifferenceBanner({required this.difference});

  final double difference;

  @override
  Widget build(BuildContext context) {
    final bool isMissing = difference < 0;
    return TintedBanner(
      icon: Icons.warning_amber_rounded,
      title: isMissing
          ? context.l10n.cashRegisterShortage
          : context.l10n.cashRegisterSurplus,
      background: AppColors.warningSurface,
      foreground: AppColors.warningText,
      trailingText:
          '${isMissing ? '−' : '+'} '
          '${MoneyFormatter.format(difference.abs())}',
    );
  }
}

class _CloseError extends StatelessWidget {
  const _CloseError({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: context.l10n.commonBack, onPressed: onBack),
        ],
      ),
    );
  }
}

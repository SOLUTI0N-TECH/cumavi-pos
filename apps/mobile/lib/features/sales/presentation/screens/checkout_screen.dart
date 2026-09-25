import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/selectable_tile.dart';
import '../../../../core/widgets/tinted_banner.dart';
import '../../../cash_register/presentation/widgets/quick_amount_selector.dart';
import '../../domain/entities/sale.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../view_data/payment_method_view_data.dart';

/// Payment screen: total, method, cash received and change.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    required this.saleNumberLabel,
    required this.onBack,
    required this.onCompleted,
    super.key,
  });

  final String saleNumberLabel;
  final VoidCallback onBack;

  /// Called with the registered sale so the caller can show the receipt.
  final void Function(Sale sale) onCompleted;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _receivedController = TextEditingController();

  @override
  void dispose() {
    _receivedController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(double amount) {
    _receivedController.text = MoneyFormatter.amountOnly(amount);
    context.read<CheckoutCubit>().amountReceivedChanged(amount);
  }

  List<double> _quickAmounts(double total) {
    final double rounded = (total / 50).ceil() * 50;
    return <double>[
      if (rounded > total) rounded,
      rounded + 50,
      rounded + 150,
    ].take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (BuildContext context, CheckoutState state) {
            if (state.status == CheckoutStatus.completed &&
                state.sale != null) {
              widget.onCompleted(state.sale!);
            }
            if (state.status == CheckoutStatus.failure &&
                state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
              );
            }
          },
          builder: (BuildContext context, CheckoutState state) {
            final CheckoutCubit cubit = context.read<CheckoutCubit>();

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
                    title: l10n.salesCheckoutTitle,
                    subtitle: l10n.salesCheckoutSubtitle(
                      widget.saleNumberLabel,
                      l10n.itemCount(state.cart.itemCount),
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
                      _TotalCard(
                        total: state.total,
                        onSeeDetail: widget.onBack,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        l10n.salesCheckoutPaymentMethodLabel,
                        style: AppTextStyles.bodyStrong.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm + 2,
                        crossAxisSpacing: AppSpacing.sm + 2,
                        childAspectRatio: 2.5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: PaymentMethod.values
                            .map(
                              (PaymentMethod method) => SelectableTile(
                                label: method.localizedName(l10n),
                                icon: method.icon,
                                iconColor: method.tintColor,
                                iconBackground: method.tintSurface,
                                isSelected: state.paymentMethod == method,
                                onTap: () =>
                                    cubit.paymentMethodSelected(method),
                              ),
                            )
                            .toList(),
                      ),
                      if (state.isCashPayment) ...<Widget>[
                        const SizedBox(height: AppSpacing.xxl),
                        LabeledField(
                          label: l10n.salesCheckoutAmountReceivedLabel,
                          child: AmountInputField(
                            controller: _receivedController,
                            onChanged: (String value) =>
                                cubit.amountReceivedChanged(
                                  MoneyFormatter.tryParse(value),
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        QuickAmountSelector(
                          amounts: _quickAmounts(state.total),
                          selectedAmount: state.amountReceived,
                          onAmountSelected: _selectQuickAmount,
                          leadingLabel: l10n.salesCheckoutExactAmount,
                          onLeadingSelected: () =>
                              _selectQuickAmount(state.total),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TintedBanner(
                          title: l10n.salesCheckoutChangeTitle,
                          subtitle:
                              '${MoneyFormatter.format(state.effectiveAmountReceived)} '
                              '− ${MoneyFormatter.format(state.total)}',
                          background: AppColors.successSurface,
                          foreground: AppColors.successTextStrong,
                          trailingText: MoneyFormatter.format(state.change),
                          trailingStyle: AppTextStyles.amountMd.copyWith(
                            fontSize: 28,
                            color: AppColors.successTextStrong,
                          ),
                        ),
                      ],
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
                    label: l10n.salesCheckoutConfirmButton,
                    icon: Icons.check_rounded,
                    isLoading: state.status == CheckoutStatus.submitting,
                    onPressed: state.canConfirm ? cubit.confirm : null,
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

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.onSeeDetail});

  final double total;
  final VoidCallback onSeeDetail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.salesCheckoutTotalLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.72),
                  ),
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
                        text: MoneyFormatter.amountOnly(total),
                        style: AppTextStyles.amountXl.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextButton(
              onPressed: onSeeDetail,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.white.withValues(alpha: 0.12),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: Text(l10n.salesCheckoutSeeDetailButton),
            ),
          ),
        ],
      ),
    );
  }
}

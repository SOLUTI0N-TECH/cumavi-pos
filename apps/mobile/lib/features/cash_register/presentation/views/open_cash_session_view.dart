import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/floating_nav_insets.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../auth/domain/entities/session_info.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../cubit/cash_register_cubit.dart';
import '../cubit/cash_register_state.dart';
import '../widgets/quick_amount_selector.dart';

/// Ventas tab while the drawer is closed: register the opening float and
/// start selling. There are no shifts, so this is the only gate.
class OpenCashSessionView extends StatefulWidget {
  const OpenCashSessionView({super.key});

  @override
  State<OpenCashSessionView> createState() => _OpenCashSessionViewState();
}

class _OpenCashSessionViewState extends State<OpenCashSessionView> {
  static const List<double> _presetAmounts = <double>[0, 100, 200, 500];

  final TextEditingController _amountController = TextEditingController(
    text: MoneyFormatter.amountOnly(200),
  );

  double? get _amount => MoneyFormatter.tryParse(_amountController.text);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _openDrawer() async {
    final double amount = _amount ?? 0;
    final bool opened = await context.read<CashRegisterCubit>().open(amount);
    if (!mounted) return;
    if (!opened) {
      final AppLocalizations l10n = context.l10n;
      final Failure? failure = context.read<CashRegisterCubit>().state.failure;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure?.localizedMessage(l10n) ?? l10n.cashRegisterOpenFailed,
          ),
        ),
      );
    }
  }

  void _selectPreset(double amount) {
    setState(() {
      _amountController.text = MoneyFormatter.amountOnly(amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final SessionInfo session = context.watch<SessionCubit>().state;
    final bool isSubmitting = context.select<CashRegisterCubit, bool>(
      (CashRegisterCubit cubit) =>
          cubit.state.status == CashRegisterStatus.submitting,
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(
          top: AppSpacing.xl,
          bottom: context.bottomNavClearance,
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ScreenHeader(
              title: l10n.cashRegisterTitle,
              trailing: StatusPill(
                label: l10n.cashRegisterClosedStatus,
                icon: Icons.lock_outline_rounded,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: AppCard(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              borderRadius: BorderRadius.circular(AppRadius.xxxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 56,
                    width: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(AppRadius.lg + 2),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md + 2),
                  Text(
                    l10n.cashRegisterOpenHeadline,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.cashRegisterOpenDescription,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LabeledField(
                    label: l10n.cashRegisterOpeningAmountLabel,
                    child: AmountInputField(
                      controller: _amountController,
                      underlinedStyle: true,
                      fontSize: 46,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md + 2),
                  QuickAmountSelector(
                    amounts: _presetAmounts,
                    selectedAmount: _amount,
                    onAmountSelected: _selectPreset,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    color: AppColors.surfaceMuted,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    borderRadius: BorderRadius.circular(AppRadius.lg + 2),
                    child: Column(
                      children: <Widget>[
                        KeyValueRow(
                          label: l10n.cashRegisterCashierLabel,
                          value:
                              session.user?.fullName ??
                              l10n.cashRegisterNoCashier,
                          valueStyle: AppTextStyles.bodySmallStrong,
                        ),
                        const SizedBox(height: AppSpacing.sm + 2),
                        KeyValueRow(
                          label: l10n.cashRegisterOpenedAtLabel,
                          value: DateFormatter.shortDateTime(DateTime.now()),
                          valueStyle: AppTextStyles.bodySmallStrong,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
            ),
            child: PrimaryButton(
              label: l10n.cashRegisterOpenAction,
              icon: Icons.lock_open_rounded,
              isLoading: isSubmitting,
              onPressed: _amount == null ? null : _openDrawer,
            ),
          ),
        ],
      ),
    );
  }
}

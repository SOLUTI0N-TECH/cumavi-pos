import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../../../sales/presentation/view_data/payment_method_view_data.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';
import '../view_data/business_view_data.dart';

/// Registration step 4: inventory categories, accepted payment methods and
/// the optional NIT.
class SalesSetupScreen extends StatefulWidget {
  const SalesSetupScreen({
    required this.onBack,
    required this.onCompleted,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onCompleted;

  @override
  State<SalesSetupScreen> createState() => _SalesSetupScreenState();
}

class _SalesSetupScreenState extends State<SalesSetupScreen> {
  final TextEditingController _taxIdController = TextEditingController();

  @override
  void dispose() {
    _taxIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<RegistrationCubit, RegistrationState>(
          listener: (BuildContext context, RegistrationState state) {
            if (state.status == RegistrationStatus.completed) {
              widget.onCompleted();
            }
            if (state.status == RegistrationStatus.failure &&
                state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure!.localizedMessage(context.l10n)),
                ),
              );
            }
          },
          builder: (BuildContext context, RegistrationState state) {
            final RegistrationCubit cubit = context.read<RegistrationCubit>();
            final AppLocalizations l10n = context.l10n;

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    0,
                  ),
                  child: StepProgressHeader(
                    currentStep: 4,
                    totalSteps: 4,
                    stepLabel: l10n.authSalesSetupStepLabel,
                    onBack: widget.onBack,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xxl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    children: <Widget>[
                      Text(
                        l10n.authSalesSetupTitle,
                        style: AppTextStyles.display.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.authSalesSetupSubtitle,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        l10n.authSalesSetupCategoriesTitle,
                        style: AppTextStyles.bodyStrong,
                      ),
                      Text.rich(
                        TextSpan(
                          text: l10n.authSalesSetupSuggestedFor,
                          style: AppTextStyles.caption,
                          children: <InlineSpan>[
                            TextSpan(
                              text: state.businessType.label(l10n),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: state.suggestedCategories
                            .map(
                              (String category) => _CategoryChip(
                                label: category,
                                isSelected: state.selectedCategories.contains(
                                  category,
                                ),
                                onTap: () => cubit.categoryToggled(category),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        l10n.authSalesSetupPaymentMethodsTitle,
                        style: AppTextStyles.bodyStrong,
                      ),
                      Text(
                        l10n.authSalesSetupPaymentMethodsSubtitle,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 2.8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: PaymentMethod.values
                            .map(
                              (PaymentMethod method) => _PaymentMethodCheckbox(
                                method: method,
                                isSelected: state.acceptedPaymentMethods
                                    .contains(method),
                                onChanged: () =>
                                    cubit.paymentMethodToggled(method),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      LabeledField(
                        label: l10n.authSalesSetupTaxIdLabel,
                        optionalText: l10n.authSalesSetupTaxIdOptional,
                        helperText: l10n.authSalesSetupTaxIdHelper,
                        child: TextField(
                          controller: _taxIdController,
                          onChanged: cubit.taxIdChanged,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: l10n.authSalesSetupTaxIdHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  child: PrimaryButton(
                    label: l10n.authSalesSetupSubmit,
                    isLoading: state.isSubmitting,
                    onPressed: state.canSubmitSetup ? cubit.submitSetup : null,
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.ink : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: 42,
          padding: EdgeInsets.only(left: isSelected ? 10 : 16, right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.borderSoft,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isSelected) ...<Widget>[
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.white,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCheckbox extends StatelessWidget {
  const _PaymentMethodCheckbox({
    required this.method,
    required this.isSelected,
    required this.onChanged,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surface : AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onChanged,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.background,
              width: 2,
            ),
          ),
          child: Row(
            children: <Widget>[
              Checkbox(value: isSelected, onChanged: (_) => onChanged()),
              Icon(method.icon, size: 20, color: method.tintColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  method.localizedName(context.l10n),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';

/// Closing screen of the registration: the business is ready and the first
/// steps are laid out.
class BusinessReadyScreen extends StatelessWidget {
  const BusinessReadyScreen({
    required this.onCreateProduct,
    required this.onOpenCashRegister,
    required this.onGoHome,
    super.key,
  });

  final VoidCallback onCreateProduct;
  final VoidCallback onOpenCashRegister;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RegistrationState state = context.watch<RegistrationCubit>().state;
    final String businessName = state.businessName.trim().isEmpty
        ? l10n.authBusinessReadyDefaultName
        : state.businessName.trim();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxxl + AppSpacing.xxl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                ),
                children: <Widget>[
                  Center(
                    child: _BusinessBadge(initials: _initialsOf(businessName)),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.authBusinessReadyTitle(businessName),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.display.copyWith(fontSize: 30),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.authBusinessReadySubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _FirstStepsCard(
                    onCreateProduct: onCreateProduct,
                    onOpenCashRegister: onOpenCashRegister,
                  ),
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
                    label: l10n.authBusinessReadyAddFirstProduct,
                    icon: Icons.add_rounded,
                    onPressed: onCreateProduct,
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onGoHome,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.inkSoft,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(l10n.authBusinessReadyGoHome),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initialsOf(String name) {
    final List<String> parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}

class _BusinessBadge extends StatelessWidget {
  const _BusinessBadge({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      width: 104,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          BusinessAvatar(
            initials: initials,
            size: 104,
            fontSize: 38,
            borderRadius: 32,
          ),
          Positioned(
            right: -8,
            bottom: -8,
            child: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstStepsCard extends StatelessWidget {
  const _FirstStepsCard({
    required this.onCreateProduct,
    required this.onOpenCashRegister,
  });

  final VoidCallback onCreateProduct;
  final VoidCallback onOpenCashRegister;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              l10n.authBusinessReadyFirstStepsTitle,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.inkSoft,
              ),
            ),
          ),
          _StepRow(
            leading: const _StepLeading.done(),
            title: l10n.authBusinessReadyStepAccountTitle,
            subtitle: l10n.authBusinessReadyStepAccountDone,
            isDone: true,
          ),
          const Divider(height: 1),
          _StepRow(
            leading: const _StepLeading.number('2', isFilled: true),
            title: l10n.authBusinessReadyStepProductsTitle,
            subtitle: l10n.authBusinessReadyStepProductsSubtitle,
            onTap: onCreateProduct,
          ),
          const Divider(height: 1),
          _StepRow(
            leading: const _StepLeading.number('3'),
            title: l10n.authBusinessReadyStepSellTitle,
            subtitle: l10n.authBusinessReadyStepSellSubtitle,
            onTap: onOpenCashRegister,
          ),
        ],
      ),
    );
  }
}

class _StepLeading extends StatelessWidget {
  const _StepLeading.done() : label = null, isFilled = false;

  const _StepLeading.number(this.label, {this.isFilled = false});

  final String? label;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(
        height: 36,
        width: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.successRing,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 18,
          color: AppColors.successText,
        ),
      );
    }

    return Container(
      height: 36,
      width: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFilled ? AppColors.ink : AppColors.surface,
        shape: BoxShape.circle,
        border: isFilled ? null : Border.all(color: AppColors.ink, width: 2),
      ),
      child: Text(
        label!,
        style: AppTextStyles.bodyStrong.copyWith(
          color: isFilled ? AppColors.white : AppColors.ink,
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDone = false,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
        child: Row(
          children: <Widget>[
            leading,
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}

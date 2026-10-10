import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../auth/domain/entities/business_profile.dart';
import '../../../auth/domain/entities/session_info.dart';
import '../../../auth/domain/entities/user_account.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../../auth/presentation/view_data/business_view_data.dart';
import '../../../cash_register/presentation/cubit/cash_register_cubit.dart';
import '../cubit/sign_out_cubit.dart';
import '../widgets/business_logo.dart';

/// "Más": the account, the business and everything outside the three tabs.
/// Opened from the avatar on Inicio.
class MoreScreen extends StatelessWidget {
  const MoreScreen({
    required this.onBack,
    required this.onEditBusiness,
    required this.onOpenCategories,
    required this.onOpenSalesHistory,
    required this.onOpenStockMovements,
    required this.onOpenOrders,
    required this.onOpenOnlineStore,
    required this.onSignedOut,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onEditBusiness;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenSalesHistory;
  final VoidCallback onOpenStockMovements;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenOnlineStore;

  /// Called once the session is closed, to go back to the sign in.
  final VoidCallback onSignedOut;

  Future<void> _confirmSignOut(BuildContext context) async {
    final AppLocalizations l10n = context.l10n;
    // The drawer state is only loaded once Ventas is opened: refresh it so
    // the warning is right when coming straight from Inicio.
    final CashRegisterCubit cashRegister = context.read<CashRegisterCubit>();
    await cashRegister.load();
    if (!context.mounted) return;
    final bool cashOpen = cashRegister.state.isOpen;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.accountSignOutTitle),
        content: Text(
          cashOpen ? l10n.accountSignOutCashOpen : l10n.accountSignOutMessage,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorText),
            child: Text(l10n.accountSignOut),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      await context.read<SignOutCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final SessionInfo session = context.watch<SessionCubit>().state;

    return BlocListener<SignOutCubit, SignOutState>(
      listener: (BuildContext context, SignOutState state) {
        if (state.status == SignOutStatus.signedOut) onSignedOut();
        if (state.status == SignOutStatus.failure && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.xl,
              AppSpacing.pageHorizontal,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              PushedScreenHeader(title: l10n.accountMoreTitle, onBack: onBack),
              const SizedBox(height: AppSpacing.xl),
              if (session.user case final UserAccount user)
                _ProfileCard(user: user),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(l10n.accountSectionBusiness),
              if (session.business case final BusinessProfile business)
                _BusinessTile(business: business, onTap: onEditBusiness),
              _MenuTile(
                icon: Icons.storefront_outlined,
                title: l10n.onlineStoreTitle,
                subtitle: l10n.accountOnlineStoreHint,
                onTap: onOpenOnlineStore,
              ),
              const SizedBox(height: AppSpacing.xl),
              _SectionTitle(l10n.accountSectionOperation),
              _MenuTile(
                icon: Icons.shopping_bag_outlined,
                title: l10n.ordersTitle,
                subtitle: l10n.accountOrdersHint,
                onTap: onOpenOrders,
              ),
              _MenuTile(
                icon: Icons.receipt_long_outlined,
                title: l10n.salesHistoryTitle,
                subtitle: l10n.accountOperationSalesHistoryHint,
                onTap: onOpenSalesHistory,
              ),
              _MenuTile(
                icon: Icons.swap_vert_rounded,
                title: l10n.inventoryMovementsTitle,
                subtitle: l10n.accountOperationMovementsHint,
                onTap: onOpenStockMovements,
              ),
              _MenuTile(
                icon: Icons.category_outlined,
                title: l10n.catalogCategoriesTitle,
                subtitle: l10n.accountOperationCategoriesHint,
                onTap: onOpenCategories,
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<SignOutCubit, SignOutState>(
                builder: (BuildContext context, SignOutState state) {
                  return OutlinedButton.icon(
                    onPressed: state.isBusy
                        ? null
                        : () => _confirmSignOut(context),
                    icon: state.isBusy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout_rounded, size: 20),
                    label: Text(l10n.accountSignOut),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorText,
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppColors.borderSoft),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const _AppVersion(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.captionSmallStrong.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String method = switch (user.provider) {
      AuthProvider.google => l10n.accountProviderGoogle,
      AuthProvider.email => l10n.accountProviderEmail,
      AuthProvider.phone => l10n.accountProviderPhone,
    };
    final String? contact =
        user.email ??
        (user.phoneNumber == null ? null : '+591 ${user.phoneNumber}');

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Container(
            height: 56,
            width: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: Text(
              user.initials,
              style: AppTextStyles.bodyLargeStrong.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(user.fullName, style: AppTextStyles.bodyLargeStrong),
                if (contact != null)
                  Text(
                    contact,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.accountSignedInWith(method),
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessTile extends StatelessWidget {
  const _BusinessTile({required this.business, required this.onTap});

  final BusinessProfile business;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? taxId = business.taxId;

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              BusinessLogo(
                initials: business.initials,
                logoPath: business.logoPath,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(business.name, style: AppTextStyles.bodyLargeStrong),
                    Text(
                      '${business.type.label(l10n)} · '
                      '${business.department.displayName}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      taxId == null
                          ? l10n.accountBusinessNoTaxId
                          : l10n.receiptTaxId(taxId),
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Tooltip(
                message: l10n.accountBusinessEdit,
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One entry of the "Operación" section.
class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 22, color: AppColors.ink),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: AppTextStyles.bodyStrong),
                    Text(subtitle, style: AppTextStyles.captionSmall),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppVersion extends StatelessWidget {
  const _AppVersion();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        final PackageInfo? info = snapshot.data;
        if (info == null) return const SizedBox.shrink();
        return Text(
          l10n.accountVersion(l10n.appTitle, info.version, info.buildNumber),
          textAlign: TextAlign.center,
          style: AppTextStyles.captionSmall,
        );
      },
    );
  }
}

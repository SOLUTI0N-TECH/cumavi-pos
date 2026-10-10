import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/floating_nav_insets.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/tinted_banner.dart';
import '../../../orders/presentation/widgets/online_orders_card.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/cash_session_card.dart';
import '../widgets/payment_breakdown_card.dart';

/// Home tab: how the day is going and the shortcuts to sell or restock.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.onStartSale,
    required this.onOpenInventory,
    required this.onOpenMore,
    required this.onOpenSalesHistory,
    required this.onOpenOrders,
    super.key,
  });

  final VoidCallback onStartSale;
  final VoidCallback onOpenInventory;

  /// Opens the "Más" hub (account, business, settings).
  final VoidCallback onOpenMore;

  /// "Ver historial" on the today's sales card.
  final VoidCallback onOpenSalesHistory;

  /// The online orders inbox.
  final VoidCallback onOpenOrders;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (BuildContext context, DashboardState state) {
            if (state.isLoading && state.snapshot == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final DashboardSnapshot? snapshot = state.snapshot;
            if (snapshot == null) {
              return _DashboardError(
                message:
                    state.failure?.localizedMessage(l10n) ??
                    l10n.dashboardLoadError,
                onRetry: () => context.read<DashboardCubit>().load(),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().load(),
              child: ListView(
                padding: EdgeInsets.only(
                  top: AppSpacing.xl,
                  bottom: context.bottomNavClearance,
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: _DashboardTopBar(
                      onOpenMore: widget.onOpenMore,
                      snapshot: snapshot,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: _Greeting(snapshot: snapshot),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: CashSessionCard(
                      snapshot: snapshot,
                      onStartSale: widget.onStartSale,
                      onOpenHistory: widget.onOpenSalesHistory,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: OnlineOrdersCard(onOpen: widget.onOpenOrders),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: PaymentBreakdownCard(summary: snapshot.sales),
                  ),
                  if (snapshot.lowStockCount > 0) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: TintedBanner(
                        icon: Icons.warning_amber_rounded,
                        title: l10n.dashboardLowStockTitle(
                          snapshot.lowStockCount,
                        ),
                        subtitle: l10n.dashboardLowStockSubtitle,
                        background: AppColors.warningSurface,
                        foreground: AppColors.warningText,
                        onTap: widget.onOpenInventory,
                        showChevron: true,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({required this.snapshot, required this.onOpenMore});

  final DashboardSnapshot snapshot;
  final VoidCallback onOpenMore;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Row(
      children: <Widget>[
        const BrandMark(size: 48, showWordmark: false),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                snapshot.business?.name ?? l10n.commonDefaultBusinessName,
                style: AppTextStyles.bodyLargeStrong,
                overflow: TextOverflow.ellipsis,
              ),
              Text(l10n.appTitle, style: AppTextStyles.captionSmall),
            ],
          ),
        ),
        IconButton(
          // No notification service yet: say so instead of doing nothing.
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.dashboardNoNotifications)),
          ),
          tooltip: l10n.dashboardNotificationsTooltip,
          icon: const Icon(Icons.notifications_none_rounded, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            minimumSize: const Size(44, 44),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Tooltip(
          message: l10n.accountOpenMenuTooltip,
          child: Material(
            color: AppColors.ink,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onOpenMore,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: 44,
                child: Center(
                  child: Text(
                    snapshot.user?.initials ?? '?',
                    style: AppTextStyles.bodySmallStrong.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final String? firstName = snapshot.user?.firstName;
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          firstName == null
              ? l10n.dashboardGreeting
              : l10n.dashboardGreetingWithName(firstName),
          style: AppTextStyles.headline,
        ),
        Text(
          DateFormatter.longDate(DateTime.now()),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

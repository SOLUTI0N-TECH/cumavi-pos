import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_chip_bar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/order.dart';
import '../cubit/orders_inbox_cubit.dart';
import '../view_data/order_view_data.dart';

/// "Pedidos en línea": the orders that come from the store's web catalog,
/// by state.
class OrdersInboxScreen extends StatefulWidget {
  const OrdersInboxScreen({
    required this.onBack,
    required this.onOpenOrder,
    required this.onImport,
    this.clock,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<Order> onOpenOrder;

  /// "Importar pedido" from a WhatsApp link.
  final VoidCallback onImport;

  /// "Hace 8 min"; tests pin it.
  final DateTime Function()? clock;

  @override
  State<OrdersInboxScreen> createState() => _OrdersInboxScreenState();
}

class _OrdersInboxScreenState extends State<OrdersInboxScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersInboxCubit>().load();
  }

  Future<void> _simulate() async {
    final AppLocalizations l10n = context.l10n;
    final Failure? failure = await context
        .read<OrdersInboxCubit>()
        .simulateNewOrder();
    if (failure != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.localizedMessage(l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final OrdersInboxCubit cubit = context.read<OrdersInboxCubit>();
    final DateTime now = (widget.clock ?? DateTime.now)();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OrdersInboxCubit, OrdersInboxState>(
          builder: (BuildContext context, OrdersInboxState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    AppSpacing.lg,
                  ),
                  child: PushedScreenHeader(
                    title: l10n.ordersTitle,
                    subtitle: l10n.ordersSubtitle,
                    onBack: widget.onBack,
                    trailing: IconButton.filledTonal(
                      tooltip: l10n.ordersImportTooltip,
                      onPressed: widget.onImport,
                      icon: const Icon(Icons.add_link_rounded),
                    ),
                  ),
                ),
                FilterChipBar<OrdersFilter>(
                  selectedValue: state.filter,
                  onSelected: cubit.filterSelected,
                  options: <FilterChipOption<OrdersFilter>>[
                    for (final OrdersFilter filter in OrdersFilter.values)
                      FilterChipOption<OrdersFilter>(
                        value: filter,
                        label: switch (filter) {
                          OrdersFilter.newOrders => l10n.ordersFilterNew,
                          OrdersFilter.inProgress =>
                            l10n.ordersFilterInProgress,
                          OrdersFilter.delivered => l10n.ordersFilterDelivered,
                          OrdersFilter.cancelled => l10n.ordersFilterCancelled,
                        },
                        badge: '${state.countOf(filter)}',
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _body(context, state, now)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, OrdersInboxState state, DateTime now) {
    final AppLocalizations l10n = context.l10n;
    if (state.status == OrdersInboxStatus.loading && state.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final List<Order> orders = state.visible;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        _DemoBanner(simulating: state.simulating, onSimulate: _simulate),
        const SizedBox(height: AppSpacing.md),
        if (state.status == OrdersInboxStatus.failure)
          EmptyStateView(
            icon: Icons.cloud_off_rounded,
            title: l10n.failureUnexpected,
            message: state.failure?.localizedMessage(l10n) ?? '',
            action: OutlinedButton(
              onPressed: context.read<OrdersInboxCubit>().load,
              child: Text(l10n.commonRetry),
            ),
          )
        else if (orders.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: switch (state.filter) {
                OrdersFilter.newOrders => l10n.ordersEmptyNewTitle,
                _ => l10n.ordersEmptyTitle,
              },
              message: switch (state.filter) {
                OrdersFilter.newOrders => l10n.ordersEmptyNewMessage,
                _ => l10n.ordersEmptyMessage,
              },
            ),
          )
        else
          for (final Order order in orders)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: OrderCard(
                order: order,
                now: now,
                onTap: () => widget.onOpenOrder(order),
              ),
            ),
      ],
    );
  }
}

/// Reminds that orders are simulated until the API is connected, and lets
/// the seller bring one in.
class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.simulating, required this.onSimulate});

  final bool simulating;
  final VoidCallback onSimulate;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.science_outlined, color: AppColors.infoText),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.ordersDemoTitle,
                  style: AppTextStyles.bodySmallStrong.copyWith(
                    color: AppColors.infoText,
                  ),
                ),
                Text(
                  l10n.ordersDemoMessage,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.infoText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: simulating ? null : onSimulate,
            child: simulating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.ordersDemoSimulate),
          ),
        ],
      ),
    );
  }
}

/// One order of the inbox: number, state, customer, what and how much.
class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.order,
    required this.now,
    required this.onTap,
    super.key,
  });

  final Order order;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final BorderRadius radius = BorderRadius.circular(AppRadius.xl);

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    order.formattedNumber,
                    style: AppTextStyles.bodyLargeStrong,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      OrderTexts.placedAt(l10n, order.createdAt, now),
                      style: AppTextStyles.captionSmall,
                    ),
                  ),
                  StatusPill(
                    label: order.status.label(l10n),
                    background: order.status.background,
                    foreground: order.status.foreground,
                    height: 26,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Icon(
                    order.fulfillment.icon,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${order.customer.name} · '
                      '${order.fulfillment.label(l10n)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmallStrong,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                OrderTexts.summary(l10n, order),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.captionSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      order.paymentMethod.localizedName(l10n),
                      style: AppTextStyles.captionSmall,
                    ),
                  ),
                  if (order.source == OrderSource.whatsappImport) ...<Widget>[
                    const Icon(
                      Icons.link_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Text(
                    MoneyFormatter.format(order.total),
                    style: AppTextStyles.bodyStrong,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

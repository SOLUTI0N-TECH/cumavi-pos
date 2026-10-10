import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/cubit/orders_badge_cubit.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Scaffold of the three POS sections. The floating navigation bar sits on
/// top of the current branch, which keeps its own state. It also announces
/// the online orders that arrive while the app is open.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    required this.navigationShell,
    this.onOpenOrder,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  /// Opens an order announced by the "new order" alert.
  final ValueChanged<String>? onOpenOrder;

  /// One destination per branch, in the router's branch order.
  static List<BottomNavDestination> destinations(AppLocalizations l10n) =>
      <BottomNavDestination>[
        BottomNavDestination(icon: Icons.home_outlined, label: l10n.shellHome),
        BottomNavDestination(
          icon: Icons.shopping_cart_outlined,
          label: l10n.shellSales,
        ),
        BottomNavDestination(
          icon: Icons.inventory_2_outlined,
          label: l10n.shellInventory,
        ),
      ];

  void _announce(BuildContext context, OrdersBadgeState state) {
    final AppLocalizations l10n = context.l10n;
    final Order order = state.arrived!;
    final ValueChanged<String>? open = onOpenOrder;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.orderArrivedToast(
              order.formattedNumber,
              MoneyFormatter.format(order.total),
            ),
          ),
          action: open == null
              ? null
              : SnackBarAction(
                  label: l10n.orderArrivedView,
                  onPressed: () => open(order.id),
                ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBadgeCubit, OrdersBadgeState>(
      listenWhen: (OrdersBadgeState previous, OrdersBadgeState current) =>
          current.arrivals > previous.arrivals && current.arrived != null,
      listener: _announce,
      child: Scaffold(
        body: navigationShell,
        extendBody: true,
        bottomNavigationBar: AppBottomNavBar(
          destinations: destinations(context.l10n),
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (int index) => navigationShell.goBranch(
            index,
            // Tapping the active tab returns it to its first screen.
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}

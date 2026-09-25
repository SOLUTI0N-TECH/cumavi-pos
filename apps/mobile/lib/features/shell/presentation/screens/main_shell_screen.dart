import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../widgets/app_bottom_nav_bar.dart';

/// Scaffold of the three POS sections. The floating navigation bar sits on
/// top of the current branch, which keeps its own state.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

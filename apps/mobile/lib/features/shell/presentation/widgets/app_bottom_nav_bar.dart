import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One destination of the floating navigation bar.
class BottomNavDestination {
  const BottomNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Floating charcoal pill with the three POS sections. The selected tab is a
/// white pill with its label, the others keep icon + label in muted grey.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<BottomNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal,
          0,
          AppSpacing.pageHorizontal,
          AppSpacing.lg,
        ),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x47292526),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            // Each item fills the bar's height; otherwise the selected pill
            // shrinks to the height of its label.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List<Widget>.generate(destinations.length, (int index) {
              final BottomNavDestination destination = destinations[index];
              return Expanded(
                child: _NavItem(
                  destination: destination,
                  isSelected: index == currentIndex,
                  onTap: () => onDestinationSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isSelected
        ? AppColors.ink
        : AppColors.textOnDarkMuted;

    return Semantics(
      selected: isSelected,
      button: true,
      label: destination.label,
      child: Material(
        color: isSelected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(destination.icon, size: 22, color: foreground),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  destination.label,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: foreground,
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

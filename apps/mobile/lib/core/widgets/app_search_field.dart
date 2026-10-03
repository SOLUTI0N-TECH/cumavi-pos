import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Editable search input used by the catalog and the inventory list.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.hintText,
    this.controller,
    this.onChanged,
    this.autofocus = false,
    this.focused = false,
    this.trailing,
    this.keyboardType,
    super.key,
  });

  final String hintText;
  final TextEditingController? controller;

  /// E.g. digits to search a sale by number.
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  /// Paints the charcoal focus border without requiring keyboard focus.
  final bool focused;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.input,
        border: Border.all(
          color: focused ? AppColors.ink : AppColors.surface,
          width: focused ? 2 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search_rounded, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: autofocus,
              keyboardType: keyboardType,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPlaceholder,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Non-editable search bar that opens the full-screen catalog when tapped.
class SearchFieldButton extends StatelessWidget {
  const SearchFieldButton({
    required this.hintText,
    required this.onTap,
    this.onScanTap,
    super.key,
  });

  final String hintText;
  final VoidCallback onTap;
  final VoidCallback? onScanTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.input,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.input,
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 18, right: 8),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search_rounded, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hintText,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPlaceholder,
                  ),
                ),
              ),
              if (onScanTap != null)
                IconButton(
                  onPressed: onScanTap,
                  tooltip: context.l10n.commonScanBarcodeTooltip,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
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

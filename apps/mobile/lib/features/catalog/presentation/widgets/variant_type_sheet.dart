import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/selectable_tile.dart';

/// Asks for the name of a variant type: the quick choices `Color` and
/// `Talla` plus a custom one when adding, or a new name when renaming.
class VariantTypeSheet extends StatefulWidget {
  const VariantTypeSheet({
    required this.existingNames,
    this.currentName,
    super.key,
  });

  /// Types the product already has: their quick choice is hidden and the
  /// name cannot be repeated.
  final List<String> existingNames;

  /// Name being changed; `null` when adding a type.
  final String? currentName;

  /// Returns the name of the new type, or `null` when dismissed.
  static Future<String?> showAdd(
    BuildContext context, {
    required List<String> existingNames,
  }) {
    final AppLocalizations l10n = context.l10n;
    return AppBottomSheet.show<String>(
      context: context,
      title: l10n.catalogVariantTypeSheetTitle,
      subtitle: l10n.catalogVariantTypeSheetSubtitle,
      builder: (_) => VariantTypeSheet(existingNames: existingNames),
    );
  }

  /// Returns the new name of [currentName], or `null` when dismissed.
  static Future<String?> showRename(
    BuildContext context, {
    required String currentName,
    required List<String> existingNames,
  }) {
    return AppBottomSheet.show<String>(
      context: context,
      title: context.l10n.catalogVariantTypeRenameTitle,
      builder: (_) => VariantTypeSheet(
        existingNames: existingNames,
        currentName: currentName,
      ),
    );
  }

  @override
  State<VariantTypeSheet> createState() => _VariantTypeSheetState();
}

class _VariantTypeSheetState extends State<VariantTypeSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currentName ?? '',
  );

  bool get _isRename => widget.currentName != null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isTaken(String name) {
    final String normalized = name.trim().toLowerCase();
    return widget.existingNames.any(
      (String existing) =>
          existing.toLowerCase() == normalized &&
          existing != widget.currentName,
    );
  }

  bool _canSubmit(String name) => name.trim().isNotEmpty && !_isTaken(name);

  void _submit() {
    final String name = _controller.text.trim();
    if (_canSubmit(name)) Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<_QuickType> quickTypes = <_QuickType>[
      _QuickType(
        name: l10n.catalogVariantTypeColor,
        description: l10n.catalogVariantTypeColorDescription,
        icon: Icons.palette_outlined,
        iconColor: AppColors.violetText,
        iconBackground: AppColors.violetSurface,
      ),
      _QuickType(
        name: l10n.catalogVariantTypeSize,
        description: l10n.catalogVariantTypeSizeDescription,
        icon: Icons.straighten_rounded,
        iconColor: AppColors.infoText,
        iconBackground: AppColors.infoSurface,
      ),
    ].where((_QuickType type) => !_isTaken(type.name)).toList();

    return Padding(
      // Keeps the custom name field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!_isRename)
            for (final _QuickType type in quickTypes) ...<Widget>[
              SelectableTile(
                label: type.name,
                supportingText: type.description,
                icon: type.icon,
                iconColor: type.iconColor,
                iconBackground: type.iconBackground,
                isSelected: false,
                onTap: () => Navigator.of(context).pop(type.name),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          if (!_isRename && quickTypes.isNotEmpty)
            const SizedBox(height: AppSpacing.md),
          LabeledField(
            label: _isRename
                ? l10n.catalogVariantTypeNameLabel
                : l10n.catalogVariantTypeCustomLabel,
            child: TextField(
              controller: _controller,
              autofocus: _isRename,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: l10n.catalogVariantTypeCustomHint,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (BuildContext context, TextEditingValue value, _) {
              return PrimaryButton(
                label: _isRename ? l10n.commonSave : l10n.catalogVariantTypeAdd,
                icon: _isRename ? Icons.check_rounded : Icons.add_rounded,
                onPressed: _canSubmit(value.text) ? _submit : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickType {
  const _QuickType({
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/product_variant.dart';
import 'variant_type_sheet.dart';

/// Edits the ways a product varies (`Color`, `Talla`) and their values:
/// removable value chips, quick suggestions for the common types and a field
/// to type any other value (shoe sizes, materials...).
class VariantOptionsEditor extends StatelessWidget {
  const VariantOptionsEditor({
    required this.options,
    required this.onAddValue,
    required this.onRemoveValue,
    required this.onRename,
    required this.onRemove,
    super.key,
  });

  final List<VariantOption> options;
  final void Function(int optionIndex, String value) onAddValue;
  final void Function(int optionIndex, String value) onRemoveValue;
  final void Function(int optionIndex, String name) onRename;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < options.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          _OptionBlock(
            // Keyed by name so a removed type does not hand its typed text
            // to the next one.
            key: ValueKey<String>(options[index].name.toLowerCase()),
            option: options[index],
            onAddValue: (String value) => onAddValue(index, value),
            onRemoveValue: (String value) => onRemoveValue(index, value),
            onRename: () => _rename(context, index),
            onRemove: () => _remove(context, index),
          ),
        ],
      ],
    );
  }

  Future<void> _rename(BuildContext context, int index) async {
    final String? name = await VariantTypeSheet.showRename(
      context,
      currentName: options[index].name,
      existingNames: options
          .map((VariantOption option) => option.name)
          .toList(),
    );
    if (name != null) onRename(index, name);
  }

  /// A type without values goes right away; one with values takes its
  /// variants (and their stock) with it, so the seller confirms first.
  Future<void> _remove(BuildContext context, int index) async {
    final VariantOption option = options[index];
    if (option.values.isEmpty) {
      onRemove(index);
      return;
    }
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await AppBottomSheet.show<bool>(
      context: context,
      title: l10n.catalogVariantRemoveTypeTitle(option.name),
      subtitle: l10n.catalogVariantRemoveTypeMessage,
      builder: (BuildContext sheetContext) => Row(
        children: <Widget>[
          Expanded(
            child: SecondaryButton(
              label: l10n.commonCancel,
              onPressed: () => Navigator.of(sheetContext).pop(false),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(
              label: l10n.catalogVariantRemoveTypeConfirm,
              height: 58,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) onRemove(index);
  }
}

/// Quick values offered for the well-known types.
enum _KnownType { color, size, other }

class _OptionBlock extends StatefulWidget {
  const _OptionBlock({
    required this.option,
    required this.onAddValue,
    required this.onRemoveValue,
    required this.onRename,
    required this.onRemove,
    super.key,
  });

  final VariantOption option;
  final ValueChanged<String> onAddValue;
  final ValueChanged<String> onRemoveValue;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  @override
  State<_OptionBlock> createState() => _OptionBlockState();
}

class _OptionBlockState extends State<_OptionBlock> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Adds the typed value and keeps the keyboard open for the next one.
  void _addTypedValue() {
    final String value = _controller.text.trim();
    if (value.isEmpty) return;
    widget.onAddValue(value);
    _controller.clear();
    _focusNode.requestFocus();
  }

  _KnownType _typeOf(AppLocalizations l10n) {
    final String name = widget.option.name.toLowerCase();
    if (name == l10n.catalogVariantTypeColor.toLowerCase()) {
      return _KnownType.color;
    }
    if (name == l10n.catalogVariantTypeSize.toLowerCase()) {
      return _KnownType.size;
    }
    return _KnownType.other;
  }

  /// Common values not used yet. Letter sizes are not offered once the
  /// seller typed numeric ones (shoes).
  List<String> _suggestions(AppLocalizations l10n, _KnownType type) {
    final List<String> values = widget.option.values;
    final String source = switch (type) {
      _KnownType.color => l10n.catalogVariantColorSuggestions,
      _KnownType.size
          when values.any((String value) => num.tryParse(value) != null) =>
        '',
      _KnownType.size => l10n.catalogVariantSizeSuggestions,
      _KnownType.other => '',
    };
    final Set<String> used = values
        .map((String value) => value.toLowerCase())
        .toSet();
    return source
        .split(',')
        .map((String value) => value.trim())
        .where(
          (String value) =>
              value.isNotEmpty && !used.contains(value.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final VariantOption option = widget.option;
    final _KnownType type = _typeOf(l10n);
    final List<String> suggestions = _suggestions(l10n, type);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(switch (type) {
                _KnownType.color => Icons.palette_outlined,
                _KnownType.size => Icons.straighten_rounded,
                _KnownType.other => Icons.sell_outlined,
              }, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        option.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onRename,
                      tooltip: l10n.catalogVariantOptionRenameTooltip,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                tooltip: l10n.catalogVariantOptionRemoveTooltip,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppColors.errorText,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (option.values.isEmpty)
                  _EmptyValuesHint(text: l10n.catalogVariantOptionEmptyHint)
                else
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      for (final String value in option.values)
                        _ValueChip(
                          label: value,
                          removeTooltip: l10n.catalogVariantValueRemoveTooltip(
                            value,
                          ),
                          onRemove: () => widget.onRemoveValue(value),
                        ),
                    ],
                  ),
                if (suggestions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      for (final String value in suggestions)
                        _SuggestionChip(
                          label: value,
                          onTap: () => widget.onAddValue(value),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        // A custom type has no suggestions: the seller
                        // types its first value right away.
                        autofocus:
                            type == _KnownType.other && option.values.isEmpty,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        // Providing onEditingComplete keeps the keyboard
                        // open between values.
                        onEditingComplete: _addTypedValue,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: l10n.catalogVariantValueHint(option.name),
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textPlaceholder,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      onPressed: _addTypedValue,
                      tooltip: l10n.catalogVariantValueAddTooltip,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(46, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyValuesHint extends StatelessWidget {
  const _EmptyValuesHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.warningIcon,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.warningText,
            ),
          ),
        ),
      ],
    );
  }
}

/// A value of the type, removable with its "x".
class _ValueChip extends StatelessWidget {
  const _ValueChip({
    required this.label,
    required this.removeTooltip,
    required this.onRemove,
  });

  final String label;
  final String removeTooltip;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 14, right: 2),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: AppTextStyles.bodySmallStrong.copyWith(
              color: AppColors.white,
            ),
          ),
          Tooltip(
            message: removeTooltip,
            child: InkResponse(
              onTap: onRemove,
              radius: 16,
              child: const SizedBox.square(
                dimension: 32,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.textOnDarkMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A common value not used yet (`M`, `Negro`); one tap adds it.
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: 36,
          padding: const EdgeInsets.only(left: 10, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.add_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

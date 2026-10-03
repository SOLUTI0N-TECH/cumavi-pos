import 'package:flutter/material.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/usecases/category_rules.dart';

/// Asks for a category name, to create one or rename it. The sheet stays
/// open and shows the error (e.g. the name is taken) until [onSubmit]
/// succeeds.
class CategoryNameSheet extends StatefulWidget {
  const CategoryNameSheet({
    required this.onSubmit,
    required this.submitLabel,
    this.initialName = '',
    super.key,
  });

  /// Saves the name; returns the failure, or `null` when it worked.
  final Future<Failure?> Function(String name) onSubmit;
  final String submitLabel;
  final String initialName;

  /// `true` when the name was saved.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String submitLabel,
    required Future<Failure?> Function(String name) onSubmit,
    String initialName = '',
  }) async {
    final bool? saved = await AppBottomSheet.show<bool>(
      context: context,
      title: title,
      builder: (_) => CategoryNameSheet(
        onSubmit: onSubmit,
        submitLabel: submitLabel,
        initialName: initialName,
      ),
    );
    return saved ?? false;
  }

  @override
  State<CategoryNameSheet> createState() => _CategoryNameSheetState();
}

class _CategoryNameSheetState extends State<CategoryNameSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );
  Failure? _failure;
  bool _saving = false;

  bool get _canSubmit {
    final String name = _controller.text.trim();
    return !_saving &&
        name.length >= CategoryRules.minNameLength &&
        name != widget.initialName.trim();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() {
      _saving = true;
      _failure = null;
    });
    final Failure? failure = await widget.onSubmit(_controller.text.trim());
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      _failure = failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      // Keeps the field above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: CategoryRules.maxNameLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() => _failure = null),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: l10n.catalogCategoryNameHint,
              errorText: _failure?.localizedMessage(l10n),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: widget.submitLabel,
            icon: Icons.check_rounded,
            isLoading: _saving,
            onPressed: _canSubmit ? _submit : null,
          ),
        ],
      ),
    );
  }
}

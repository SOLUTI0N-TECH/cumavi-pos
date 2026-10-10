import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/store_settings.dart';
import '../../domain/usecases/store_settings_usecases.dart';

/// Names and texts of the opening hours.
abstract final class OpeningHoursTexts {
  /// `Lunes` for 1 … `Domingo` for 7.
  static String weekday(int weekday) {
    // 2024-01-01 was a Monday.
    final String name = DateFormat.EEEE('es')
        .format(DateTime(2024, 1, weekday));
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }

  /// `09:00`
  static String time(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  /// `09:00–13:00 · 15:00–20:00`, or `null` when closed.
  static String? ranges(List<OpeningHoursRange> ranges) => ranges.isEmpty
      ? null
      : ranges
            .map(
              (OpeningHoursRange r) => '${time(r.opensAt)}–${time(r.closesAt)}',
            )
            .join(' · ');
}

/// Edits the ranges of one weekday; returns them (empty = closed), or
/// `null` when dismissed.
class OpeningHoursSheet extends StatefulWidget {
  const OpeningHoursSheet({
    required this.weekday,
    required this.ranges,
    super.key,
  });

  final int weekday;
  final List<OpeningHoursRange> ranges;

  static Future<List<OpeningHoursRange>?> show(
    BuildContext context, {
    required int weekday,
    required List<OpeningHoursRange> ranges,
  }) => AppBottomSheet.show<List<OpeningHoursRange>>(
    context: context,
    title: OpeningHoursTexts.weekday(weekday),
    subtitle: context.l10n.onlineStoreHoursSheetSubtitle,
    builder: (_) => OpeningHoursSheet(weekday: weekday, ranges: ranges),
  );

  @override
  State<OpeningHoursSheet> createState() => _OpeningHoursSheetState();
}

class _OpeningHoursSheetState extends State<OpeningHoursSheet> {
  late final List<OpeningHoursRange> _ranges = List<OpeningHoursRange>.of(
    widget.ranges,
  );

  Failure? get _failure => StoreSettingsRules.checkOpeningHours(_ranges);

  Future<void> _pick(int index, {required bool opens}) async {
    final OpeningHoursRange range = _ranges[index];
    final int minutes = opens ? range.opensAt : range.closesAt;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    final int value = picked.hour * 60 + picked.minute;
    setState(() {
      _ranges[index] = OpeningHoursRange(
        weekday: widget.weekday,
        opensAt: opens ? value : range.opensAt,
        closesAt: opens ? range.closesAt : value,
      );
    });
  }

  void _add() {
    // After the last range, or a usual morning.
    final int start = _ranges.isEmpty
        ? 9 * 60
        : (_ranges
                      .map((OpeningHoursRange r) => r.closesAt)
                      .reduce((int a, int b) => a > b ? a : b) +
                  60)
              .clamp(0, 22 * 60);
    setState(() {
      _ranges.add(
        OpeningHoursRange(
          weekday: widget.weekday,
          opensAt: start,
          closesAt: (start + 4 * 60).clamp(start + 30, 24 * 60),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Failure? failure = _failure;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_ranges.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              l10n.onlineStoreClosedDay,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        for (int i = 0; i < _ranges.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pick(i, opens: true),
                    child: Text(OpeningHoursTexts.time(_ranges[i].opensAt)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text('–'),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pick(i, opens: false),
                    child: Text(OpeningHoursTexts.time(_ranges[i].closesAt)),
                  ),
                ),
                IconButton(
                  tooltip: l10n.onlineStoreRemoveRange,
                  onPressed: () => setState(() => _ranges.removeAt(i)),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.onlineStoreAddRange),
          ),
        ),
        if (failure != null)
          Text(
            failure.localizedMessage(l10n),
            style: AppTextStyles.captionSmall.copyWith(
              color: AppColors.errorText,
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: l10n.commonSave,
          icon: Icons.check_rounded,
          onPressed: failure != null
              ? null
              : () => Navigator.of(context).pop<List<OpeningHoursRange>>(
                  _ranges..sort(
                    (OpeningHoursRange a, OpeningHoursRange b) =>
                        a.opensAt.compareTo(b.opensAt),
                  ),
                ),
        ),
      ],
    );
  }
}

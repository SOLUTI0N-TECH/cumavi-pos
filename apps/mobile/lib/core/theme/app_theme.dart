import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

/// Single source of truth for the [ThemeData] used by the app.
abstract final class AppTheme {
  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      primary: AppColors.ink,
      onPrimary: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppFonts.family,
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: AppFonts.family,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.subtitle,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerSoft,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.divider,
          disabledForegroundColor: AppColors.textPlaceholder,
          minimumSize: const Size.fromHeight(60),
          textStyle: AppTextStyles.bodyLargeStrong,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(58),
          textStyle: AppTextStyles.bodyStrong,
          side: const BorderSide(color: AppColors.borderSoft),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.infoText,
          textStyle: AppTextStyles.bodySmallStrong,
          minimumSize: const Size(44, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPlaceholder,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.ink, width: 2),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 2),
      ),
      // White dialogs like the rest of the surfaces (no Material tint).
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        titleTextStyle: AppTextStyles.title,
        contentTextStyle: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.input),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.ink
              : AppColors.surface;
        }),
        side: const BorderSide(color: AppColors.border, width: 1.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm / 1.6),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll<Color>(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.info
              : AppColors.divider;
        }),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

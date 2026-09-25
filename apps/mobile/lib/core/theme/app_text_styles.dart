import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Typography scale built on Outfit, the Cumavi brand typeface.
///
/// Amount styles enable tabular figures so prices do not shift width while
/// they change.
abstract final class AppTextStyles {
  static TextStyle _outfit(
    double size, {
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    Color color = AppColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: AppFonts.family,
      fontSize: size,
      fontWeight: weight,
      height: height == null ? null : height / size,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Big money figures (cash drawer, totals).
  static TextStyle get amountXl => _outfit(
    42,
    weight: FontWeight.w700,
    height: 50,
    letterSpacing: -0.8,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle get amountLg => _outfit(
    30,
    weight: FontWeight.w700,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle get amountMd => _outfit(
    24,
    weight: FontWeight.w700,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  static TextStyle get amountSm => _outfit(
    17,
    weight: FontWeight.w700,
  ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Welcome headlines on the auth flow.
  static TextStyle get display =>
      _outfit(34, weight: FontWeight.w700, height: 40, letterSpacing: -0.6);

  /// Screen titles ("Ventas", "Inventario").
  static TextStyle get headline =>
      _outfit(30, weight: FontWeight.w700, height: 36, letterSpacing: -0.5);

  /// Section headlines inside cards.
  static TextStyle get title =>
      _outfit(25, weight: FontWeight.w700, height: 30, letterSpacing: -0.3);

  /// Pushed-screen app bar titles.
  static TextStyle get subtitle =>
      _outfit(22, weight: FontWeight.w700, height: 26);

  static TextStyle get bodyLargeStrong => _outfit(18, weight: FontWeight.w600);

  static TextStyle get bodyLarge => _outfit(17, weight: FontWeight.w400);

  static TextStyle get bodyStrong => _outfit(16, weight: FontWeight.w600);

  static TextStyle get body => _outfit(16, weight: FontWeight.w400);

  static TextStyle get bodySmallStrong => _outfit(15, weight: FontWeight.w600);

  static TextStyle get bodySmall => _outfit(15, weight: FontWeight.w400);

  static TextStyle get label =>
      _outfit(14, weight: FontWeight.w600, color: AppColors.inkSoft);

  static TextStyle get caption =>
      _outfit(14, weight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle get captionSmall =>
      _outfit(13, weight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle get captionSmallStrong =>
      _outfit(13, weight: FontWeight.w600, color: AppColors.textSecondary);

  static TextStyle get micro =>
      _outfit(12, weight: FontWeight.w400, color: AppColors.textSecondary);
}

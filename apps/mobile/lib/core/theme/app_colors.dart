import 'package:flutter/material.dart';

/// Cumavi brand palette shared with `cumavi_shop_mobile`.
///
/// Semantic colors expose two variants: a `*Surface` tint used as a
/// background and a `*Text` shade that keeps a 4.5:1 contrast ratio on top of
/// it, so tinted banners stay readable.
abstract final class AppColors {
  // Brand.
  static const Color ink = Color(0xFF292526);
  static const Color inkStrong = Color(0xFF141213);
  static const Color inkSoft = Color(0xFF4A4546);

  // Text.
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF6B6E72);
  static const Color textPlaceholder = Color(0xFF75787C);
  static const Color textOnDarkMuted = Color(0xFFC9C6C7);

  // Surfaces.
  static const Color background = Color(0xFFF2F2F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F7F7);

  // Lines.
  static const Color border = Color(0xFFC5CFDB);
  static const Color borderSoft = Color(0xFFD5DAE1);
  static const Color divider = Color(0xFFE6E7E7);
  static const Color dividerSoft = Color(0xFFEEEFEF);

  // Semantic: success.
  static const Color success = Color(0xFF16A34A);
  static const Color successText = Color(0xFF15803D);
  static const Color successTextStrong = Color(0xFF166534);
  static const Color successSurface = Color(0xFFE8F6ED);
  static const Color successRing = Color(0xFFDCF1E3);

  // Semantic: warning.
  static const Color warning = Color(0xFFF5761B);
  static const Color warningText = Color(0xFF9A3412);
  static const Color warningIcon = Color(0xFFC2410C);
  static const Color warningSurface = Color(0xFFFEF0E6);

  // Semantic: error.
  static const Color error = Color(0xFFF8493B);
  static const Color errorText = Color(0xFFB42318);
  static const Color errorSurface = Color(0xFFFFF2F1);

  // Accent: info / QR.
  static const Color info = Color(0xFF2563EB);
  static const Color infoText = Color(0xFF1D4ED8);
  static const Color infoSurface = Color(0xFFEAF1FE);

  // Accent: card payments.
  static const Color gold = Color(0xFFFFD160);
  static const Color goldText = Color(0xFFA16207);
  static const Color goldSurface = Color(0xFFFFF6DC);

  // Accent: bank transfer.
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetText = Color(0xFF6D28D9);
  static const Color violetSurface = Color(0xFFF1ECFE);

  static const Color white = Color(0xFFFFFFFF);
}

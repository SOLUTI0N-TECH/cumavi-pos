import 'package:flutter/widgets.dart';

/// Corner radius scale. Cards use [xl], inputs [lg], pills [pill].
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 28;
  static const double pill = 999;

  static const BorderRadius card = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius input = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius button = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xxxl),
  );
}

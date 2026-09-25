import 'package:flutter/widgets.dart';

import 'app_spacing.dart';

/// Room taken by the floating navigation bar at the bottom of each tab.
///
/// The shell's Scaffold (`extendBody: true`) reports the bar's full height,
/// the phone's gesture or button area included, as the tabs' bottom padding.
/// Reading it here keeps content clear of the bar on every phone instead of
/// assuming a fixed height.
extension FloatingNavInsets on BuildContext {
  /// Height of the navigation bar plus the system area below it.
  double get bottomNavHeight => MediaQuery.paddingOf(this).bottom;

  /// Bottom padding for scrollables so the bar never covers the last item.
  double get bottomNavClearance => bottomNavHeight + AppSpacing.xl;
}

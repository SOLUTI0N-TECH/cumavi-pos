import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/stock_level.dart';

/// Presentation data of a [StockLevel]: the tints that tell a healthy stock
/// from a low or sold-out one, shared by badges and indicator dots.
///
/// Keeping it out of the domain lets the enum stay free of Flutter types.
extension StockLevelViewData on StockLevel {
  /// Background of the stock badge.
  Color get badgeSurface => switch (this) {
    StockLevel.healthy => AppColors.divider,
    StockLevel.low => AppColors.warningSurface,
    StockLevel.outOfStock => AppColors.errorSurface,
  };

  /// Text color on top of [badgeSurface].
  Color get badgeText => switch (this) {
    StockLevel.healthy => AppColors.inkSoft,
    StockLevel.low => AppColors.warningText,
    StockLevel.outOfStock => AppColors.errorText,
  };

  /// Solid color of the small dot next to a variant.
  Color get indicatorColor => switch (this) {
    StockLevel.healthy => AppColors.success,
    StockLevel.low => AppColors.warning,
    StockLevel.outOfStock => AppColors.error,
  };
}

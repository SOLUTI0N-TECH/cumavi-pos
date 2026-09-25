import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/business_profile.dart';

/// Labels and icons for [BusinessType].
extension BusinessTypeViewData on BusinessType {
  String label(AppLocalizations l10n) => switch (this) {
    BusinessType.clothingAndFootwear =>
      l10n.authBusinessTypeClothingAndFootwear,
    BusinessType.neighborhoodStore => l10n.authBusinessTypeNeighborhoodStore,
    BusinessType.foodAndDrinks => l10n.authBusinessTypeFoodAndDrinks,
    BusinessType.beautyAndCare => l10n.authBusinessTypeBeautyAndCare,
    BusinessType.technology => l10n.authBusinessTypeTechnology,
    BusinessType.other => l10n.authBusinessTypeOther,
  };

  IconData get icon => switch (this) {
    BusinessType.clothingAndFootwear => Icons.checkroom_rounded,
    BusinessType.neighborhoodStore => Icons.storefront_outlined,
    BusinessType.foodAndDrinks => Icons.local_cafe_outlined,
    BusinessType.beautyAndCare => Icons.auto_awesome_outlined,
    BusinessType.technology => Icons.smartphone_rounded,
    BusinessType.other => Icons.more_horiz_rounded,
  };
}

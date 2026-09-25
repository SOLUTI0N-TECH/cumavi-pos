import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/widgets/product_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/load_app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  Product seed(String id) => CatalogSeedData.products().firstWhere(
    (Product product) => product.id == id,
  );

  testWidgets('variant summary fits without changing the row height', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final Product withVariants = seed('p-001');
    final Product simple = seed('p-006');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: AppLocale.bolivianSpanish,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: Column(
            children: <Widget>[
              ProductListTile(product: withVariants),
              ProductListTile(product: simple),
            ],
          ),
        ),
      ),
    );

    expect(find.text('15 variantes · Color, Talla'), findsOneWidget);
    expect(find.textContaining('variante'), findsOneWidget);
    final Finder tiles = find.byType(ProductListTile);
    expect(
      tester.getSize(tiles.first).height,
      tester.getSize(tiles.last).height,
    );
  });
}

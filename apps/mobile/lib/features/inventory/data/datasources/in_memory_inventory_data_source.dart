import '../../../catalog/data/datasources/catalog_seed_data.dart';
import '../../../catalog/data/datasources/in_memory_product_data_source.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../domain/entities/stock_movement.dart';

/// Storage contract of the stock ledger. The backend applies the movements
/// to the stock itself; the mock asks the in-memory catalog to do it.
abstract interface class InventoryDataSource {
  Future<List<StockMovement>> insertMovements(
    List<StockMovementDraft> drafts, {
    required String userName,
  });

  Future<List<StockMovement>> fetchMovements();
}

/// Mock ledger kept in memory, seeded with the initial stock of the demo
/// catalog and a few receipts and adjustments.
final class InMemoryInventoryDataSource implements InventoryDataSource {
  InMemoryInventoryDataSource({
    required InMemoryProductDataSource products,
    Duration? latency,
  }) : _products = products,
       _latency = latency ?? const Duration(milliseconds: 260),
       _movements = _seed(CatalogSeedData.products());

  final InMemoryProductDataSource _products;
  final Duration _latency;
  final List<StockMovement> _movements;
  int _sequence = 0;

  @override
  Future<List<StockMovement>> insertMovements(
    List<StockMovementDraft> drafts, {
    required String userName,
  }) async {
    await Future<void>.delayed(_latency);
    // All or nothing: the catalog refuses the whole batch if one change
    // would leave a stock below zero.
    final List<StockChangeResult> results = await _products.applyStockChanges(
      <StockChange>[
        for (final StockMovementDraft draft in drafts)
          StockChange(
            productId: draft.productId,
            variantId: draft.variantId,
            delta: draft.delta,
          ),
      ],
    );
    final DateTime now = DateTime.now();
    final List<StockMovement> recorded = <StockMovement>[
      for (int i = 0; i < drafts.length; i++)
        StockMovement(
          id: 'mov-${++_sequence}-${now.microsecondsSinceEpoch}',
          productId: drafts[i].productId,
          productName: results[i].productName,
          variantId: drafts[i].variantId,
          variantLabel: results[i].variantLabel,
          delta: drafts[i].delta,
          stockAfter: results[i].stockAfter,
          type: drafts[i].type,
          reason: drafts[i].reason,
          note: drafts[i].note,
          unitCost: drafts[i].unitCost,
          saleId: drafts[i].saleId,
          userName: userName,
          createdAt: now,
        ),
    ];
    _movements.addAll(recorded);
    return recorded;
  }

  @override
  Future<List<StockMovement>> fetchMovements() async {
    await Future<void>.delayed(_latency);
    return List<StockMovement>.unmodifiable(_movements);
  }

  static const String _owner = 'Carla Mamani';

  /// History consistent with the seeded stock: every product starts with an
  /// "Inventario inicial" and a few later movements lead to today's stock.
  static List<StockMovement> _seed(List<Product> products) {
    final DateTime today = DateTime.now();
    DateTime daysAgo(int days) =>
        DateTime(today.year, today.month, today.day - days, 10, 15);

    // Later movements per product/variant: (delta, days ago, type…).
    final Map<(String, String?), List<_SeedMove>> later =
        <(String, String?), List<_SeedMove>>{
          ('p-008', null): <_SeedMove>[
            const _SeedMove(
              delta: 10,
              daysAgo: 3,
              type: StockMovementType.purchase,
              unitCost: 28,
              note: 'Importadora Andina',
            ),
          ],
          ('p-011', 'negra/m'): <_SeedMove>[
            const _SeedMove(
              delta: 6,
              daysAgo: 2,
              type: StockMovementType.purchase,
              unitCost: 38,
              note: 'Textiles El Alto',
            ),
          ],
          ('p-014', null): <_SeedMove>[
            const _SeedMove(
              delta: -1,
              daysAgo: 1,
              type: StockMovementType.adjustment,
              reason: AdjustmentReason.damage,
              note: 'Costura abierta',
            ),
          ],
        };

    final List<StockMovement> movements = <StockMovement>[];
    int sequence = 0;
    void add({
      required Product product,
      required ProductVariant? variant,
      required int delta,
      required int stockAfter,
      required DateTime at,
      required StockMovementType type,
      AdjustmentReason? reason,
      String? note,
      double? unitCost,
    }) {
      movements.add(
        StockMovement(
          id: 'mov-seed-${++sequence}',
          productId: product.id,
          productName: product.name,
          variantId: variant?.id,
          variantLabel: variant?.label,
          delta: delta,
          stockAfter: stockAfter,
          type: type,
          reason: reason,
          note: note,
          unitCost: unitCost,
          userName: _owner,
          createdAt: at,
        ),
      );
    }

    for (final Product product in products) {
      final List<ProductVariant?> targets = product.hasVariants
          ? product.variants
          : <ProductVariant?>[null];
      for (final ProductVariant? variant in targets) {
        final int current = variant?.stockQuantity ?? product.stockQuantity;
        final List<_SeedMove> moves =
            later[(product.id, variant?.id)] ?? const <_SeedMove>[];
        int stock =
            current -
            moves.fold(0, (int sum, _SeedMove move) => sum + move.delta);
        if (stock > 0) {
          add(
            product: product,
            variant: variant,
            delta: stock,
            stockAfter: stock,
            at: product.createdAt,
            type: StockMovementType.initial,
          );
        }
        for (final _SeedMove move in moves) {
          stock += move.delta;
          add(
            product: product,
            variant: variant,
            delta: move.delta,
            stockAfter: stock,
            at: daysAgo(move.daysAgo),
            type: move.type,
            reason: move.reason,
            note: move.note,
            unitCost: move.unitCost,
          );
        }
      }
    }
    return movements;
  }
}

final class _SeedMove {
  const _SeedMove({
    required this.delta,
    required this.daysAgo,
    required this.type,
    this.reason,
    this.note,
    this.unitCost,
  });

  final int delta;
  final int daysAgo;
  final StockMovementType type;
  final AdjustmentReason? reason;
  final String? note;
  final double? unitCost;
}

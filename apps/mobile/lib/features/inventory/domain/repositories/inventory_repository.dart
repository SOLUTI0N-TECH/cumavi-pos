import '../../../../core/utils/result.dart';
import '../entities/stock_movement.dart';

/// The stock ledger: the only way the stock of a product changes.
abstract interface class InventoryRepository {
  /// Applies every draft or none (`insufficientStock` when one would leave
  /// the stock below zero) and returns the recorded movements.
  Future<Result<List<StockMovement>>> recordMovements(
    List<StockMovementDraft> drafts,
  );

  /// Movements matching [query], newest first.
  Future<Result<List<StockMovement>>> getMovements(StockMovementQuery query);
}

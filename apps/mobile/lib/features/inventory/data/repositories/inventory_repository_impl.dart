import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/in_memory_inventory_data_source.dart';

final class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl({
    required InventoryDataSource dataSource,
    required SessionRepository sessionRepository,
  }) : _dataSource = dataSource,
       _sessionRepository = sessionRepository;

  final InventoryDataSource _dataSource;
  final SessionRepository _sessionRepository;

  @override
  Future<Result<List<StockMovement>>> recordMovements(
    List<StockMovementDraft> drafts,
  ) async {
    if (drafts.isEmpty) {
      return const Success<List<StockMovement>>(<StockMovement>[]);
    }
    try {
      return Success<List<StockMovement>>(
        await _dataSource.insertMovements(
          drafts,
          userName: _sessionRepository.currentCashierName,
        ),
      );
    } on DataSourceException catch (exception) {
      return Failed<List<StockMovement>>(switch (exception.code) {
        FailureCode.productNotFound => NotFoundFailure(
          exception.code,
          detail: exception.detail,
        ),
        _ => ConflictFailure(exception.code, detail: exception.detail),
      });
    }
  }

  @override
  Future<Result<List<StockMovement>>> getMovements(
    StockMovementQuery query,
  ) async {
    try {
      final List<StockMovement> movements =
          (await _dataSource.fetchMovements()).where(query.matches).toList()
            ..sort(
              (StockMovement a, StockMovement b) =>
                  b.createdAt.compareTo(a.createdAt),
            );
      final int? limit = query.limit;
      return Success<List<StockMovement>>(
        limit == null ? movements : movements.take(limit).toList(),
      );
    } on DataSourceException catch (exception) {
      return Failed<List<StockMovement>>(UnexpectedFailure(exception.code));
    }
  }
}

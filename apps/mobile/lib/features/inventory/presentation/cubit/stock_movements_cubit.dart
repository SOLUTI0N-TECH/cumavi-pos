import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/stock_usecases.dart';

/// Kinds of movement the history filters by.
enum MovementFilter {
  all(null),
  purchases(<StockMovementType>{StockMovementType.purchase}),
  adjustments(<StockMovementType>{StockMovementType.adjustment}),
  sales(<StockMovementType>{
    StockMovementType.sale,
    StockMovementType.cancellation,
    StockMovementType.saleReturn,
  }),
  initial(<StockMovementType>{StockMovementType.initial});

  const MovementFilter(this.types);

  final Set<StockMovementType>? types;
}

/// How far back the history looks.
enum MovementPeriod { last7Days, last30Days, all }

enum StockMovementsStatus { loading, ready, failure }

final class StockMovementsState extends Equatable {
  const StockMovementsState({
    this.status = StockMovementsStatus.loading,
    this.filter = MovementFilter.all,
    this.period = MovementPeriod.last30Days,
    this.movements = const <StockMovement>[],
    this.failure,
  });

  final StockMovementsStatus status;
  final MovementFilter filter;
  final MovementPeriod period;
  final List<StockMovement> movements;
  final Failure? failure;

  StockMovementsState copyWith({
    StockMovementsStatus? status,
    MovementFilter? filter,
    MovementPeriod? period,
    List<StockMovement>? movements,
    Failure? failure,
  }) => StockMovementsState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    period: period ?? this.period,
    movements: movements ?? this.movements,
    failure: failure,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    filter,
    period,
    movements,
    failure,
  ];
}

/// "Movimientos de stock" of the whole store, or of one product.
class StockMovementsCubit extends Cubit<StockMovementsState> {
  StockMovementsCubit({
    required GetStockMovements getStockMovements,
    this.productId,
    DateTime Function()? clock,
  }) : _getStockMovements = getStockMovements,
       _clock = clock ?? DateTime.now,
       // A product's history is short: show all of it.
       super(
         StockMovementsState(
           period: productId == null
               ? MovementPeriod.last30Days
               : MovementPeriod.all,
         ),
       );

  final GetStockMovements _getStockMovements;
  final DateTime Function() _clock;

  /// `null` shows every product.
  final String? productId;

  Future<void> load() => _search();

  Future<void> filterSelected(MovementFilter filter) {
    emit(state.copyWith(filter: filter));
    return _search();
  }

  Future<void> periodSelected(MovementPeriod period) {
    emit(state.copyWith(period: period));
    return _search();
  }

  Future<void> _search() async {
    emit(state.copyWith(status: StockMovementsStatus.loading));
    final DateTime now = _clock();
    final StockMovementQuery query = StockMovementQuery(
      productId: productId,
      types: state.filter.types,
      from: switch (state.period) {
        MovementPeriod.last7Days => DateTime(now.year, now.month, now.day - 6),
        MovementPeriod.last30Days => DateTime(
          now.year,
          now.month,
          now.day - 29,
        ),
        MovementPeriod.all => null,
      },
    );
    switch (await _getStockMovements(query)) {
      case Success<List<StockMovement>>(:final List<StockMovement> value):
        emit(
          state.copyWith(status: StockMovementsStatus.ready, movements: value),
        );
      case Failed<List<StockMovement>>(:final failure):
        emit(
          state.copyWith(
            status: StockMovementsStatus.failure,
            failure: failure,
          ),
        );
    }
  }
}

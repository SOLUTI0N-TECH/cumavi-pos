import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/dashboard_snapshot.dart';
import '../../domain/usecases/get_dashboard_snapshot.dart';
import 'dashboard_state.dart';

/// Loads and refreshes the home screen.
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._getDashboardSnapshot) : super(const DashboardState());

  final GetDashboardSnapshot _getDashboardSnapshot;

  Future<void> load() async {
    emit(state.copyWith(status: DashboardStatus.loading));

    switch (await _getDashboardSnapshot(const NoParams())) {
      case Success<DashboardSnapshot>(:final DashboardSnapshot value):
        emit(DashboardState(status: DashboardStatus.ready, snapshot: value));
      case Failed<DashboardSnapshot>(:final failure):
        emit(state.copyWith(status: DashboardStatus.failure, failure: failure));
    }
  }
}

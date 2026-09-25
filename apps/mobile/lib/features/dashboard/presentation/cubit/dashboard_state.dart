import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/dashboard_snapshot.dart';

enum DashboardStatus { initial, loading, ready, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.snapshot,
    this.failure,
  });

  final DashboardStatus status;
  final DashboardSnapshot? snapshot;
  final Failure? failure;

  bool get isLoading =>
      status == DashboardStatus.loading || status == DashboardStatus.initial;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSnapshot? snapshot,
    Failure? failure,
  }) {
    return DashboardState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, snapshot, failure];
}

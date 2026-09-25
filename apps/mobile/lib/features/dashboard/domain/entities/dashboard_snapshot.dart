import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/business_profile.dart';
import '../../../auth/domain/entities/user_account.dart';
import '../../../cash_register/domain/entities/cash_session.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../sales/domain/entities/daily_sales_summary.dart';

/// Everything the home screen shows, resolved in a single read.
final class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.sales,
    required this.lowStockProducts,
    this.cashSession,
    this.user,
    this.business,
  });

  final DailySalesSummary sales;
  final List<Product> lowStockProducts;

  /// `null` when the drawer is closed.
  final CashSession? cashSession;
  final UserAccount? user;
  final BusinessProfile? business;

  bool get isCashSessionOpen => cashSession?.isOpen ?? false;

  /// Opening float plus today's cash sales.
  double get cashInDrawer =>
      (cashSession?.openingAmount ?? 0) + sales.cashTotal;

  int get lowStockCount => lowStockProducts.length;

  @override
  List<Object?> get props => <Object?>[
    sales,
    lowStockProducts,
    cashSession,
    user,
    business,
  ];
}

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../../../cash_register/domain/entities/cash_session.dart';
import '../../../cash_register/domain/repositories/cash_register_repository.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../../../sales/domain/entities/daily_sales_summary.dart';
import '../../../sales/domain/repositories/sales_repository.dart';
import '../entities/dashboard_snapshot.dart';

/// Composes the home screen data out of the sales, cash drawer, catalog and
/// session sources.
final class GetDashboardSnapshot
    implements UseCase<DashboardSnapshot, NoParams> {
  const GetDashboardSnapshot({
    required SalesRepository salesRepository,
    required CashRegisterRepository cashRegisterRepository,
    required ProductRepository productRepository,
    required SessionRepository sessionRepository,
  }) : _salesRepository = salesRepository,
       _cashRegisterRepository = cashRegisterRepository,
       _productRepository = productRepository,
       _sessionRepository = sessionRepository;

  final SalesRepository _salesRepository;
  final CashRegisterRepository _cashRegisterRepository;
  final ProductRepository _productRepository;
  final SessionRepository _sessionRepository;

  @override
  Future<Result<DashboardSnapshot>> call(NoParams input) async {
    final Result<DailySalesSummary> salesResult = await _salesRepository
        .getDailySummary(DateTime.now());
    if (salesResult case Failed<DailySalesSummary>(:final Failure failure)) {
      return Failed<DashboardSnapshot>(failure);
    }

    final Result<CashSession?> sessionResult = await _cashRegisterRepository
        .getCurrentSession();
    if (sessionResult case Failed<CashSession?>(:final Failure failure)) {
      return Failed<DashboardSnapshot>(failure);
    }

    final Result<List<Product>> lowStockResult = await _productRepository
        .getLowStockProducts();
    if (lowStockResult case Failed<List<Product>>(:final Failure failure)) {
      return Failed<DashboardSnapshot>(failure);
    }

    return Success<DashboardSnapshot>(
      DashboardSnapshot(
        sales: salesResult.valueOrNull!,
        lowStockProducts: lowStockResult.valueOrNull!,
        cashSession: sessionResult.valueOrNull,
        user: _sessionRepository.currentUser,
        business: _sessionRepository.currentBusiness,
      ),
    );
  }
}

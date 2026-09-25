import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';

/// Storage contract for sales.
abstract interface class SalesDataSource {
  Future<Sale> insertSale(SaleDraft draft, {required String cashierName});

  Future<List<Sale>> fetchSales();

  Future<int> fetchNextSaleNumber();
}

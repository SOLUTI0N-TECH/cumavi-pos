import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';
import '../../domain/entities/sale_return.dart';

/// Storage contract for sales.
abstract interface class SalesDataSource {
  Future<Sale> insertSale(SaleDraft draft, {required String cashierName});

  Future<List<Sale>> fetchSales();

  Future<int> fetchNextSaleNumber();

  Future<Sale> cancelSale(
    String saleId, {
    required String reason,
    required String cancelledBy,
  });

  Future<SaleReturn> insertReturn(
    SaleReturnDraft draft, {
    required String cashierName,
  });
}

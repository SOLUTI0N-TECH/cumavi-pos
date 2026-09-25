/// How healthy the stock of a product is.
enum StockLevel {
  /// More units than [StockRules.lowStockThreshold].
  healthy,

  /// Between 1 and [StockRules.lowStockThreshold] units left.
  low,

  /// No units left; the product cannot be sold.
  outOfStock;

  bool get isSellable => this != StockLevel.outOfStock;
}

/// Domain rules about stock, kept in one place so the UI never hardcodes them.
abstract final class StockRules {
  /// At or below this quantity a product is reported as low stock.
  static const int lowStockThreshold = 5;

  static StockLevel levelFor(int quantity) {
    if (quantity <= 0) return StockLevel.outOfStock;
    if (quantity <= lowStockThreshold) return StockLevel.low;
    return StockLevel.healthy;
  }
}

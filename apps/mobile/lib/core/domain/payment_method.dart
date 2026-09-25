/// Ways a customer can pay. Shared by sales, the cash drawer, the dashboard
/// and the registration setup, so it lives in `core/domain`.
enum PaymentMethod {
  cash,
  qr,
  card,
  bankTransfer;

  /// Only cash movements change the physical money in the drawer.
  bool get affectsCashDrawer => this == PaymentMethod.cash;
}

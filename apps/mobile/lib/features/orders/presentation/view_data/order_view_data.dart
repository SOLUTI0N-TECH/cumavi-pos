import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/order.dart';

/// Words and colors of each [OrderStatus].
extension OrderStatusView on OrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.newOrder => l10n.orderStatusNew,
    OrderStatus.confirmed => l10n.orderStatusConfirmed,
    OrderStatus.ready => l10n.orderStatusReady,
    OrderStatus.delivered => l10n.orderStatusDelivered,
    OrderStatus.cancelled => l10n.orderStatusCancelled,
  };

  Color get background => switch (this) {
    OrderStatus.newOrder => AppColors.infoSurface,
    OrderStatus.confirmed => AppColors.warningSurface,
    OrderStatus.ready => AppColors.successSurface,
    OrderStatus.delivered => AppColors.divider,
    OrderStatus.cancelled => AppColors.errorSurface,
  };

  Color get foreground => switch (this) {
    OrderStatus.newOrder => AppColors.infoText,
    OrderStatus.confirmed => AppColors.warningText,
    OrderStatus.ready => AppColors.successTextStrong,
    OrderStatus.delivered => AppColors.inkSoft,
    OrderStatus.cancelled => AppColors.errorText,
  };
}

extension FulfillmentView on Fulfillment {
  String label(AppLocalizations l10n) => switch (this) {
    Fulfillment.pickup => l10n.orderFulfillmentPickup,
    Fulfillment.delivery => l10n.orderFulfillmentDelivery,
  };

  IconData get icon => switch (this) {
    Fulfillment.pickup => Icons.storefront_outlined,
    Fulfillment.delivery => Icons.delivery_dining_outlined,
  };
}

/// Texts built from an order: when it arrived, what it has, and the
/// WhatsApp message for the customer in its current state.
abstract final class OrderTexts {
  /// `Hace 8 min`, `Hoy · 15:20`, `Ayer · 15:20` or `Mié 7 oct · 15:20`.
  static String placedAt(AppLocalizations l10n, DateTime at, DateTime now) {
    final Duration age = now.difference(at);
    if (!age.isNegative && age.inMinutes < 60) {
      return l10n.orderPlacedMinutesAgo(age.inMinutes);
    }
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(at.year, at.month, at.day);
    final String time = DateFormatter.time(at);
    if (day == today) return l10n.orderPlacedToday(time);
    if (day == DateTime(now.year, now.month, now.day - 1)) {
      return l10n.orderPlacedYesterday(time);
    }
    return DateFormatter.shortDateTime(at);
  }

  /// `Polera básica (Negra · M) y 1 producto más`
  static String summary(AppLocalizations l10n, Order order) {
    final OrderLine first = order.lines.first;
    final String name = itemName(l10n, first);
    final int others = order.lines.length - 1;
    return others == 0 ? name : l10n.salesHistoryMoreProducts(others, name);
  }

  static String itemName(AppLocalizations l10n, OrderLine line) =>
      line.variantLabel == null
      ? line.productName
      : l10n.salesVariantProductName(line.productName, line.variantLabel!);

  /// What the store says to the customer at each step.
  static String whatsAppMessage(
    AppLocalizations l10n,
    Order order, {
    required String storeName,
  }) {
    final String name = order.customer.name.split(' ').first;
    final String number = order.formattedNumber;
    final String total = MoneyFormatter.format(order.total);
    return switch (order.status) {
      OrderStatus.newOrder => l10n.orderMessageNew(name, number, storeName),
      OrderStatus.confirmed =>
        order.isDelivery && order.deliveryFee > 0
            ? l10n.orderMessageConfirmedDelivery(
                name,
                number,
                MoneyFormatter.format(order.deliveryFee),
                total,
              )
            : l10n.orderMessageConfirmed(name, number, total),
      OrderStatus.ready =>
        order.isDelivery
            ? l10n.orderMessageReadyDelivery(name, number)
            : l10n.orderMessageReadyPickup(name, number, storeName),
      OrderStatus.delivered => l10n.orderMessageDelivered(name, number),
      OrderStatus.cancelled => l10n.orderMessageCancelled(
        name,
        number,
        order.cancelReason ?? '',
      ),
    };
  }
}

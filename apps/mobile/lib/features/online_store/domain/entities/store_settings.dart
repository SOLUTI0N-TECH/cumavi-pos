import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';

/// One opening range of a weekday: `Lunes 09:00–13:00`. A day can have
/// several ranges (`branch_opening_hours`).
final class OpeningHoursRange extends Equatable {
  const OpeningHoursRange({
    required this.weekday,
    required this.opensAt,
    required this.closesAt,
  });

  /// ISO weekday: 1 = Monday … 7 = Sunday, like [DateTime.weekday].
  final int weekday;

  /// Minutes since midnight.
  final int opensAt;
  final int closesAt;

  bool contains(int minuteOfDay) =>
      minuteOfDay >= opensAt && minuteOfDay < closesAt;

  bool overlaps(OpeningHoursRange other) =>
      weekday == other.weekday &&
      opensAt < other.closesAt &&
      other.opensAt < closesAt;

  @override
  List<Object?> get props => <Object?>[weekday, opensAt, closesAt];
}

/// How the store sells online (`online_stores`, plus the flags and hours of
/// the branch that sells online). The app has a single branch for now, so
/// its pickup, delivery and hours live here too.
final class StoreSettings extends Equatable {
  const StoreSettings({
    required this.isEnabled,
    required this.slug,
    this.tagline = '',
    this.whatsapp = '',
    this.deliveryNote = '',
    this.pickupEnabled = true,
    this.deliveryEnabled = false,
    this.acceptOutsideHours = false,
    this.showOutOfStock = true,
    this.onlinePaymentMethods = const <PaymentMethod>[PaymentMethod.cash],
    this.openingHours = const <OpeningHoursRange>[],
  });

  /// The web answers only while it is on (`ECO-R1`).
  final bool isEnabled;

  /// The store's part of the link: `illimani-store`.
  final String slug;
  final String tagline;

  /// National mobile number that receives the orders' messages.
  final String whatsapp;

  /// Shown on the web when the customer picks delivery.
  final String deliveryNote;
  final bool pickupEnabled;
  final bool deliveryEnabled;

  /// Orders placed while closed are taken; the web says when it opens.
  final bool acceptOutsideHours;
  final bool showOutOfStock;

  /// Methods offered at the web checkout (`payment_methods.show_online`).
  final List<PaymentMethod> onlinePaymentMethods;
  final List<OpeningHoursRange> openingHours;

  /// Ranges of [weekday], earliest first.
  List<OpeningHoursRange> rangesFor(int weekday) =>
      openingHours
          .where((OpeningHoursRange range) => range.weekday == weekday)
          .toList()
        ..sort(
          (OpeningHoursRange a, OpeningHoursRange b) =>
              a.opensAt.compareTo(b.opensAt),
        );

  /// Without hours the store is closed for web orders (`SUC-R5`).
  bool isOpenAt(DateTime moment) {
    final int minute = moment.hour * 60 + moment.minute;
    return rangesFor(moment.weekday)
        .any((OpeningHoursRange range) => range.contains(minute));
  }

  StoreSettings copyWith({
    bool? isEnabled,
    String? tagline,
    String? whatsapp,
    String? deliveryNote,
    bool? pickupEnabled,
    bool? deliveryEnabled,
    bool? acceptOutsideHours,
    bool? showOutOfStock,
    List<PaymentMethod>? onlinePaymentMethods,
    List<OpeningHoursRange>? openingHours,
  }) => StoreSettings(
    isEnabled: isEnabled ?? this.isEnabled,
    slug: slug,
    tagline: tagline ?? this.tagline,
    whatsapp: whatsapp ?? this.whatsapp,
    deliveryNote: deliveryNote ?? this.deliveryNote,
    pickupEnabled: pickupEnabled ?? this.pickupEnabled,
    deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
    acceptOutsideHours: acceptOutsideHours ?? this.acceptOutsideHours,
    showOutOfStock: showOutOfStock ?? this.showOutOfStock,
    onlinePaymentMethods: onlinePaymentMethods ?? this.onlinePaymentMethods,
    openingHours: openingHours ?? this.openingHours,
  );

  @override
  List<Object?> get props => <Object?>[
    isEnabled,
    slug,
    tagline,
    whatsapp,
    deliveryNote,
    pickupEnabled,
    deliveryEnabled,
    acceptOutsideHours,
    showOutOfStock,
    onlinePaymentMethods,
    openingHours,
  ];
}

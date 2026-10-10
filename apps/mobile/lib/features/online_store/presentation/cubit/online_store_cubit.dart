import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_links.dart';
import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/services/external_launcher.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/usecases/get_products.dart';
import '../../domain/entities/store_settings.dart';
import '../../domain/usecases/store_settings_usecases.dart';

enum OnlineStoreStatus { loading, ready, saving, failure }

final class OnlineStoreState extends Equatable {
  const OnlineStoreState({
    this.status = OnlineStoreStatus.loading,
    this.saved,
    this.draft,
    this.onlineProducts = 0,
    this.totalProducts = 0,
    this.failure,
  });

  final OnlineStoreStatus status;

  /// As stored.
  final StoreSettings? saved;

  /// As edited on screen.
  final StoreSettings? draft;
  final int onlineProducts;
  final int totalProducts;
  final Failure? failure;

  bool get hasChanges => draft != null && draft != saved;

  OnlineStoreState copyWith({
    OnlineStoreStatus? status,
    StoreSettings? saved,
    StoreSettings? draft,
    int? onlineProducts,
    int? totalProducts,
    Failure? failure,
  }) => OnlineStoreState(
    status: status ?? this.status,
    saved: saved ?? this.saved,
    draft: draft ?? this.draft,
    onlineProducts: onlineProducts ?? this.onlineProducts,
    totalProducts: totalProducts ?? this.totalProducts,
    failure: failure,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    saved,
    draft,
    onlineProducts,
    totalProducts,
    failure,
  ];
}

/// "Tienda en línea": the settings as a form, saved together.
class OnlineStoreCubit extends Cubit<OnlineStoreState> {
  OnlineStoreCubit({
    required GetStoreSettings getStoreSettings,
    required SaveStoreSettings saveStoreSettings,
    required GetProducts getProducts,
    required ExternalLauncher launcher,
  }) : _getStoreSettings = getStoreSettings,
       _launcher = launcher,
       _saveStoreSettings = saveStoreSettings,
       _getProducts = getProducts,
       super(const OnlineStoreState());

  final GetStoreSettings _getStoreSettings;
  final SaveStoreSettings _saveStoreSettings;
  final GetProducts _getProducts;
  final ExternalLauncher _launcher;

  /// The store's public link, as saved.
  String? get storeUrl => switch (state.saved) {
    final StoreSettings settings => AppLinks.storeUrl(settings.slug),
    null => null,
  };

  Future<Failure?> openStore() async {
    final String? url = storeUrl;
    if (url == null) return null;
    return (await _launcher.openLink(url)).failureOrNull;
  }

  /// Shares [message] (which carries the link) with the share sheet.
  Future<Failure?> shareStore(String message) async =>
      (await _launcher.shareText(message)).failureOrNull;

  Future<void> load() async {
    final Result<StoreSettings> settings = await _getStoreSettings(
      const NoParams(),
    );
    final Result<List<Product>> products = await _getProducts(
      const ProductQuery(),
    );
    if (isClosed) return;
    final List<Product> all = products.valueOrNull ?? const <Product>[];
    switch (settings) {
      case Success<StoreSettings>(:final StoreSettings value):
        emit(
          OnlineStoreState(
            status: OnlineStoreStatus.ready,
            saved: value,
            draft: value,
            onlineProducts: all.where((Product p) => p.showOnline).length,
            totalProducts: all.length,
          ),
        );
      case Failed<StoreSettings>(:final failure):
        emit(
          OnlineStoreState(status: OnlineStoreStatus.failure, failure: failure),
        );
    }
  }

  void enabledChanged(bool enabled) =>
      _edit((StoreSettings s) => s.copyWith(isEnabled: enabled));

  void taglineChanged(String tagline) =>
      _edit((StoreSettings s) => s.copyWith(tagline: tagline));

  void whatsappChanged(String whatsapp) =>
      _edit((StoreSettings s) => s.copyWith(whatsapp: whatsapp));

  void deliveryNoteChanged(String note) =>
      _edit((StoreSettings s) => s.copyWith(deliveryNote: note));

  void pickupChanged(bool enabled) =>
      _edit((StoreSettings s) => s.copyWith(pickupEnabled: enabled));

  void deliveryChanged(bool enabled) =>
      _edit((StoreSettings s) => s.copyWith(deliveryEnabled: enabled));

  void acceptOutsideHoursChanged(bool accept) =>
      _edit((StoreSettings s) => s.copyWith(acceptOutsideHours: accept));

  void showOutOfStockChanged(bool show) =>
      _edit((StoreSettings s) => s.copyWith(showOutOfStock: show));

  void paymentMethodToggled(PaymentMethod method) => _edit((StoreSettings s) {
    final List<PaymentMethod> methods = s.onlinePaymentMethods.contains(method)
        ? (List<PaymentMethod>.of(s.onlinePaymentMethods)..remove(method))
        : <PaymentMethod>[
            for (final PaymentMethod candidate in PaymentMethod.values)
              if (candidate == method ||
                  s.onlinePaymentMethods.contains(candidate))
                candidate,
          ];
    return s.copyWith(onlinePaymentMethods: methods);
  });

  /// Replaces the ranges of [weekday] (empty = closed that day).
  void dayHoursChanged(int weekday, List<OpeningHoursRange> ranges) => _edit(
    (StoreSettings s) => s.copyWith(
      openingHours: <OpeningHoursRange>[
        for (final OpeningHoursRange range in s.openingHours)
          if (range.weekday != weekday) range,
        ...ranges,
      ],
    ),
  );

  /// Saves the form; returns the failure, or `null` when stored.
  Future<Failure?> save() async {
    final StoreSettings? draft = state.draft;
    if (draft == null) return null;
    emit(state.copyWith(status: OnlineStoreStatus.saving));
    final Result<StoreSettings> result = await _saveStoreSettings(draft);
    if (isClosed) return result.failureOrNull;
    switch (result) {
      case Success<StoreSettings>(:final StoreSettings value):
        emit(
          state.copyWith(
            status: OnlineStoreStatus.ready,
            saved: value,
            draft: value,
          ),
        );
        return null;
      case Failed<StoreSettings>(:final failure):
        emit(state.copyWith(status: OnlineStoreStatus.ready));
        return failure;
    }
  }

  void _edit(StoreSettings Function(StoreSettings settings) change) {
    final StoreSettings? draft = state.draft;
    if (draft == null) return;
    emit(state.copyWith(draft: change(draft)));
  }
}

import 'failure_code.dart';

export 'failure_code.dart';

/// Error thrown by data sources. Repositories catch it and return a
/// `Failure` so the rest of the app never deals with exceptions.
final class DataSourceException implements Exception {
  const DataSourceException(this.code, {this.detail});

  final FailureCode code;

  /// Value the message mentions, e.g. the product that ran out of stock.
  final String? detail;

  @override
  String toString() => 'DataSourceException: ${code.name} ${detail ?? ''}';
}

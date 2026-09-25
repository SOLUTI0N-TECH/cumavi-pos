import '../error/failure.dart';

/// Explicit success/failure wrapper returned by every use case.
///
/// Callers resolve it with pattern matching:
///
/// ```dart
/// switch (await useCase(input)) {
///   case Success(:final value):
///     // ...
///   case Failed(:final failure):
///     // ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  /// The value when successful, `null` otherwise.
  T? get valueOrNull => switch (this) {
    Success<T>(:final T value) => value,
    Failed<T>() => null,
  };

  /// The failure when unsuccessful, `null` otherwise.
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failed<T>(:final Failure failure) => failure,
  };

  /// Maps the success value while keeping the failure untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success<T>(:final T value) => Success<R>(transform(value)),
    Failed<T>(:final Failure failure) => Failed<R>(failure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;
}

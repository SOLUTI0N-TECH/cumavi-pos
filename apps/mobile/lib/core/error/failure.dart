import 'package:equatable/equatable.dart';

import 'failure_code.dart';

export 'failure_code.dart';

/// Domain-level error. Data sources throw exceptions; repositories translate
/// them into a [Failure] so the presentation layer never handles exceptions.
///
/// Failures carry a [code], never user-facing text: the presentation layer
/// words them in the user's language.
sealed class Failure extends Equatable {
  const Failure(this.code, {this.detail});

  final FailureCode code;

  /// Value the message mentions, e.g. the product that ran out of stock.
  final String? detail;

  @override
  List<Object?> get props => <Object?>[code, detail];
}

/// The request was rejected because the input is not valid.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.code, {super.detail});
}

/// The requested resource does not exist.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.code, {super.detail});
}

/// The action conflicts with the current state (e.g. selling with the cash
/// drawer closed).
final class ConflictFailure extends Failure {
  const ConflictFailure(super.code, {super.detail});
}

/// Anything the app cannot classify yet.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.code = FailureCode.unexpected]);
}

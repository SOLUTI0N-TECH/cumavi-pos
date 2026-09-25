import '../utils/result.dart';

/// Contract for every asynchronous use case: one public `call`, one input,
/// one [Result].
abstract interface class UseCase<Output, Input> {
  Future<Result<Output>> call(Input input);
}

/// Input placeholder for use cases that take no arguments.
final class NoParams {
  const NoParams();
}

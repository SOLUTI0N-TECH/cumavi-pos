import '../../../../core/error/failure.dart';

/// Rules of a category name, checked before asking the repository (which
/// also checks that the name is not taken).
abstract final class CategoryRules {
  static const int minNameLength = 2;
  static const int maxNameLength = 30;

  static Failure? validateName(String name) {
    final int length = name.trim().length;
    if (length < minNameLength || length > maxNameLength) {
      return const ValidationFailure(FailureCode.categoryNameInvalid);
    }
    return null;
  }
}

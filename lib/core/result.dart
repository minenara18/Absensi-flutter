import 'package:meta/meta.dart';

/// Typed failure codes returned by repositories.
///
/// UI maps each code to a localized message; never renders exceptions
/// or `toString()` output directly.
enum FailureCode {
  /// Simulated network problem.
  network,

  /// Requested entity was not found.
  notFound,

  /// Input did not pass validation.
  validation,

  /// Anything else unexpected.
  unknown,
}

/// A typed failure with a machine-readable [code] and an optional
/// developer-oriented [detail] (never shown verbatim in UI).
@immutable
final class Failure {
  const Failure(this.code, [this.detail = '']);

  final FailureCode code;
  final String detail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Failure && other.code == code && other.detail == detail);

  @override
  int get hashCode => Object.hash(code, detail);

  @override
  String toString() => 'Failure($code, $detail)';
}

/// Sealed result type. Consume with an exhaustive `switch`:
///
/// ```dart
/// switch (result) {
///   case Ok(:final value):
///   case Err(:final failure):
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Success case carrying [value].
@immutable
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

/// Error case carrying [failure].
@immutable
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}

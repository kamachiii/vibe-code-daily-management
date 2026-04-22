/// Base exception for all application-level errors.
class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when a network or API call fails.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.cause});
}

/// Thrown when JSON parsing fails.
class ParseException extends AppException {
  const ParseException(super.message, {super.cause});
}

/// Thrown when the user is not authenticated.
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.cause});
}

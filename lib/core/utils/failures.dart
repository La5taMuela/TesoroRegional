// Simple failure class without Freezed for now
abstract class Failure {
  final String message;

  const Failure(this.message);

  const factory Failure.serverError([String? message]) = ServerError;
  const factory Failure.networkError() = NetworkError;
  const factory Failure.cacheError() = CacheError;
  const factory Failure.invalidInput([String? message]) = InvalidInput;
  const factory Failure.emptyField({required String fieldName}) = EmptyField;
  const factory Failure.invalidEmail() = InvalidEmail;
  const factory Failure.shortPassword() = ShortPassword;
  const factory Failure.invalidNumber({required String fieldName}) = InvalidNumber;
  const factory Failure.unauthorized() = Unauthorized;
  const factory Failure.notFound([String? message]) = NotFound;
  const factory Failure.permissionDenied() = PermissionDenied;
  const factory Failure.unexpected([String? message]) = Unexpected;
}

class ServerError extends Failure {
  const ServerError([String? message]) : super(message ?? 'Server error occurred');
}

class NetworkError extends Failure {
  const NetworkError() : super('Network connection error');
}

class CacheError extends Failure {
  const CacheError() : super('Cache error occurred');
}

class InvalidInput extends Failure {
  const InvalidInput([String? message]) : super(message ?? 'Invalid input');
}

class EmptyField extends Failure {
  const EmptyField({required String fieldName}) : super('$fieldName cannot be empty');
}

class InvalidEmail extends Failure {
  const InvalidEmail() : super('Invalid email format');
}

class ShortPassword extends Failure {
  const ShortPassword() : super('Password must be at least 8 characters');
}

class InvalidNumber extends Failure {
  const InvalidNumber({required String fieldName}) : super('$fieldName must be a valid number');
}

class Unauthorized extends Failure {
  const Unauthorized() : super('Unauthorized access');
}

class NotFound extends Failure {
  const NotFound([String? message]) : super(message ?? 'Resource not found');
}

class PermissionDenied extends Failure {
  const PermissionDenied() : super('Permission denied');
}

class Unexpected extends Failure {
  const Unexpected([String? message]) : super(message ?? 'Unexpected error occurred');
}

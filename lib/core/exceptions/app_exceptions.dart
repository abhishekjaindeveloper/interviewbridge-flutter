class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  ServerException([super.message = 'Internal Server Error', super.code]);
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache operation failed']);
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Network connection issue']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Unauthorized access']);
}

class AccountPendingApprovalException extends AppException {
  AccountPendingApprovalException([super.message = 'Your account is pending admin approval. Please wait for approval before logging in.']);
}

class InvalidCredentialsException extends AppException {
  InvalidCredentialsException([super.message = 'Invalid email or password.']);
}

class AccessDeniedException extends AppException {
  AccessDeniedException([super.message = 'Access Denied']);
}

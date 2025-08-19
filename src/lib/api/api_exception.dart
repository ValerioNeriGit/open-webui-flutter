class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;
  
  ApiException(this.message, {this.statusCode, this.details});
  
  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

class AuthException extends ApiException {
  AuthException(super.message, {super.statusCode});
}

class NetworkException extends ApiException {
  NetworkException(super.message) : super();
}

class ValidationException extends ApiException {
  ValidationException(super.message) : super();
}
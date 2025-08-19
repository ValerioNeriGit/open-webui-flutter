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
  AuthException(String message, {int? statusCode}) 
      : super(message, statusCode: statusCode);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}
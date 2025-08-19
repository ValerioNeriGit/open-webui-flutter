import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  // Logger for errors with full stack traces
  static final Logger _errorLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // Logger for successful operations - clean output
  static final Logger _cleanLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No stack trace for success messages
      errorMethodCount: 0,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _cleanLogger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _cleanLogger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _errorLogger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _errorLogger.e(message, error: error, stackTrace: stackTrace);
  }

  static void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    final errorMessage = '''
🔥 ERROR in $operation
   Error Type: ${error.runtimeType}
   Message: ${error.toString()}
   Location: ${stackTrace != null ? _getLocationFromStackTrace(stackTrace) : 'Unknown'}
''';
    _errorLogger.e(errorMessage, error: error, stackTrace: stackTrace);
  }

  static String _getLocationFromStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    for (final line in lines) {
      if (line.contains('.dart') && !line.contains('logger.dart')) {
        final match = RegExp(r'(\w+\.dart):(\d+)').firstMatch(line);
        if (match != null) {
          return '${match.group(1)}:${match.group(2)}';
        }
      }
    }
    return 'Unknown location';
  }

  /// Centralized operation wrapper with automatic logging
  static Future<T> wrapOperation<T>(
    String operationName, 
    Future<T> Function() operation, {
    String? startMessage,
    String? successMessage,
  }) async {
    try {
      if (startMessage != null) {
        info(startMessage);
      }
      
      final result = await operation();
      
      if (successMessage != null) {
        info(successMessage);
      }
      
      return result;
    } catch (e, stackTrace) {
      logError(operationName, e, stackTrace);
      rethrow;
    }
  }

  /// Sync version of wrapOperation
  static T wrapSync<T>(
    String operationName,
    T Function() operation, {
    String? startMessage,
    String? successMessage,
  }) {
    try {
      if (startMessage != null) {
        info(startMessage);
      }
      
      final result = operation();
      
      if (successMessage != null) {
        info(successMessage);
      }
      
      return result;
    } catch (e, stackTrace) {
      logError(operationName, e, stackTrace);
      rethrow;
    }
  }
}
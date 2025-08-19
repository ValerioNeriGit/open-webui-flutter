import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';
import '../utils/logger.dart';

// A wrapper class to hold both the response body and headers.
class ApiResponse {
  final http.Response response;
  final Map<String, dynamic> body;
  final Map<String, String> headers;

  ApiResponse(this.response)
      : body = jsonDecode(response.body),
        headers = response.headers;
  
  int get statusCode => response.statusCode;
}

class ApiClient {
  static final _instance = ApiClient._();
  ApiClient._();
  static ApiClient get instance => _instance;
  
  String? _baseUrl;
  String? _token;
  
  void configure(String baseUrl, String token) {
    _baseUrl = baseUrl;
    _token = token;
  }
  
  String get baseUrl {
    if (_baseUrl == null) {
      final error = ApiException('ApiClient not configured with base URL');
      AppLogger.logError('ApiClient.baseUrl', error, StackTrace.current);
      throw error;
    }
    return _baseUrl!;
  }
  
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }
  
  Future<http.Response> get(String path) async {
    try {
      AppLogger.debug('🌐 API GET Request', 'URL: $baseUrl$path');
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      AppLogger.debug('✅ API GET Response', 'Status: ${response.statusCode}, URL: $baseUrl$path');
      return response;
    } catch (e, stackTrace) {
      final error = ApiException('GET request failed: $e');
      AppLogger.logError('ApiClient.get($path)', error, stackTrace);
      throw error;
    }
  }
  
  // Modified to return ApiResponse which includes headers
  Future<ApiResponse> post(String path, Map<String, dynamic> body) async {
    try {
      AppLogger.debug('🌐 API POST Request', 'URL: $baseUrl$path, Body keys: ${body.keys.join(", ")}');
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      // DEBUG: Log the raw response body to diagnose parsing issues.
      AppLogger.debug('✅ API POST Response', 'Status: ${response.statusCode}, URL: $baseUrl$path, Body: ${response.body}');
      return ApiResponse(response);
    } catch (e, stackTrace) {
      final error = ApiException('POST request failed: $e');
      AppLogger.logError('ApiClient.post($path)', error, stackTrace);
      throw error;
    }
  }
  
  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    try {
      AppLogger.debug('🌐 API PUT Request', 'URL: $baseUrl$path, Body keys: ${body.keys.join(", ")}');
      final response = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      AppLogger.debug('✅ API PUT Response', 'Status: ${response.statusCode}, URL: $baseUrl$path');
      return response;
    } catch (e, stackTrace) {
      final error = ApiException('PUT request failed: $e');
      AppLogger.logError('ApiClient.put($path)', error, stackTrace);
      throw error;
    }
  }
  
  Future<http.Response> delete(String path) async {
    try {
      AppLogger.debug('🌐 API DELETE Request', 'URL: $baseUrl$path');
      final response = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      AppLogger.debug('✅ API DELETE Response', 'Status: ${response.statusCode}, URL: $baseUrl$path');
      return response;
    } catch (e, stackTrace) {
      final error = ApiException('DELETE request failed: $e');
      AppLogger.logError('ApiClient.delete($path)', error, stackTrace);
      throw error;
    }
  }
}
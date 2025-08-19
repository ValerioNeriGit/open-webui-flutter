import 'dart:convert';
import '../../api_client.dart';
import '../../api_exception.dart';
import 'completion_types.dart';

class CompletionEndpoints {
  static Future<CompletionResponse> getCompletion(CompletionRequest request) async {
    // The post method now returns an ApiResponse object
    final response = await ApiClient.instance.post(
      '/api/chat/completions',
      request.toJson(),
    );

    if (response.statusCode == 200) {
      // The body is already decoded in ApiResponse
      final data = response.body;
      return CompletionResponse.fromJson(data);
    } else {
      throw ApiException(
        // Access the raw response body for the error message
        'AI completion request failed: ${response.response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> notifyCompletion(CompletionNotificationRequest request) async {
    final response = await ApiClient.instance.post(
      '/api/chat/completed',
      request.toJson(),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Completion notification failed: ${response.response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}
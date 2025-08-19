import 'dart:convert';
import '../../api_client.dart';
import '../../api_exception.dart';
import 'completion_types.dart';

class CompletionEndpoints {
  static Future<CompletionResponse> getCompletion(CompletionRequest request) async {
    final response = await ApiClient.instance.post(
      '/api/chat/completions',
      request.toJson(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CompletionResponse.fromJson(data);
    } else {
      throw ApiException(
        'AI completion request failed: ${response.body}',
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
        'Completion notification failed: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}
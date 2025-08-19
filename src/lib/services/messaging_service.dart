import '../api/wrappers/send_message/send_message_api.dart';
import '../api/wrappers/send_message/send_message_types.dart';
import '../api/api_exception.dart';
import '../models/chat.dart';

class MessagingService {
  /// Send a message in a chat conversation
  /// This is the business logic layer that handles validation and orchestration
  static Future<String> sendMessage({
    required String chatId,
    required List<ChatMessage> currentMessages,
    required String model,
    required String prompt,
  }) async {
    // Business logic: Validation
    if (prompt.trim().isEmpty) {
      throw ValidationException('Message cannot be empty');
    }
    
    if (chatId.trim().isEmpty) {
      throw ValidationException('Chat ID is required');
    }
    
    if (model.trim().isEmpty) {
      throw ValidationException('Model is required');
    }

    try {
      // Use the API wrapper to handle the complex workflow
      final request = SendMessageRequest(
        chatId: chatId,
        currentMessages: currentMessages,
        model: model,
        prompt: prompt,
      );
      
      final response = await SendMessageApi.sendMessage(request);
      
      // Business logic: Could add analytics, caching, etc. here
      
      return response.aiContent;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send message: $e');
    }
  }

  /// Get updated messages after sending (if needed for UI state)
  static Future<List<ChatMessage>> sendMessageWithUpdatedMessages({
    required String chatId,
    required List<ChatMessage> currentMessages,
    required String model,
    required String prompt,
  }) async {
    // Same validation as above
    if (prompt.trim().isEmpty) {
      throw ValidationException('Message cannot be empty');
    }
    
    if (chatId.trim().isEmpty) {
      throw ValidationException('Chat ID is required');
    }
    
    if (model.trim().isEmpty) {
      throw ValidationException('Model is required');
    }

    try {
      final request = SendMessageRequest(
        chatId: chatId,
        currentMessages: currentMessages,
        model: model,
        prompt: prompt,
      );
      
      final response = await SendMessageApi.sendMessage(request);
      
      return response.updatedMessages;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send message: $e');
    }
  }
}
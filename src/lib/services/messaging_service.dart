import '../api/wrappers/send_message/send_message_api.dart';
import '../api/wrappers/send_message/send_message_types.dart';
import '../api/api_exception.dart';
import '../models/chat.dart';
import '../utils/logger.dart';
import 'chat_service.dart';

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

  /// Creates a new chat and sends the first message in a single operation.
  static Future<Chat> createChatAndSendFirstMessage({
    required String prompt,
    required String model,
  }) async {
    return AppLogger.wrapOperation(
      'MessagingService.createChatAndSendFirstMessage()',
      () async {
        // 1. Create the chat on the backend first to get an ID.
        final title = prompt.length > 40 ? '${prompt.substring(0, 40)}...' : prompt;
        final newChatId = await ChatService.createChat(
          title: title,
          models: [model],
        );
        AppLogger.debug('📄 New chat created with ID: $newChatId');

        // 2. Send the first message to this new chat ID.
        await sendMessage(
          chatId: newChatId,
          currentMessages: [], // It's a new chat, so no previous messages.
          model: model,
          prompt: prompt,
        );
        AppLogger.debug('📤 First message sent to new chat.');

        // 3. Fetch the final state of the chat from the server.
        // This is the source of truth and contains all messages.
        final updatedChat = await ChatService.getChat(newChatId);
        return updatedChat;
      },
      startMessage: '🚀 Creating new chat and sending first message...',
      successMessage: '✅ New chat created and first message sent successfully.',
    );
  }
}
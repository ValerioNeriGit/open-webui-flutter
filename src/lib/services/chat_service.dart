import '../api/endpoints/chats/chat_endpoints.dart';
import '../api/endpoints/chats/chat_types.dart';
import '../api/api_exception.dart';
import '../utils/logger.dart';

class ChatService {
  /// Get all chats for the current user
  static Future<List<ChatListItem>> getChats() async {
    try {
      return await ChatEndpoints.getChats();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get chats: $e');
    }
  }

  /// Get a specific chat by ID
  static Future<Chat> getChat(String chatId) async {
    try {
      AppLogger.info('📥 Fetching chat details for ID: $chatId');
      final chat = await ChatEndpoints.getChat(chatId);
      AppLogger.debug('📋 Received chat - ID: "${chat.id}", Title: "${chat.title}", Models: ${chat.models}, Messages: ${chat.messages.length}');
      return chat;
    } catch (e, stackTrace) {
      AppLogger.logError('ChatService.getChat($chatId)', e, stackTrace);
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get chat: $e');
    }
  }

  /// Create a new chat and return its ID.
  static Future<String> createChat({
    required String title,
    required List<String> models,
  }) async {
    try {
      AppLogger.info('🆕 Creating new chat: $title');
      final chatId = await ChatEndpoints.createChat(title: title, models: models);
      AppLogger.info('✅ Successfully created chat with ID: $chatId');
      return chatId;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to create chat: $e');
    }
  }

  /// Update a chat with new messages
  static Future<void> updateChat(String chatId, ChatUpdateRequest request) async {
    try {
      await ChatEndpoints.updateChat(chatId, request);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to update chat: $e');
    }
  }
}
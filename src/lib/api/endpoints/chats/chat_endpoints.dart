import 'dart:convert';
import 'dart:developer' as developer;
import '../../api_client.dart';
import '../../api_exception.dart';
import 'chat_types.dart';

class ChatEndpoints {
  static Future<List<ChatListItem>> getChats() async {
    final response = await ApiClient.instance.get('/api/v1/chats/list');
    
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((json) => ChatListItem.fromJson(json)).toList();
      } else {
        developer.log("Unexpected response type from /chats/list: ${decoded.runtimeType}");
        developer.log("Response body: ${response.body}");
        throw ApiException('Received an unexpected response format from the server.');
      }
    } else {
      throw ApiException(
        'Failed to load chats: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<Chat> getChat(String chatId) async {
    final response = await ApiClient.instance.get('/api/v1/chats/$chatId');

    if (response.statusCode == 200) {
      final dynamic chatJson = jsonDecode(response.body);
      developer.log("Raw chat response: ${response.body}");
      developer.log("Chat JSON structure: ${chatJson.keys.toList()}");
      if (chatJson['chat'] != null) {
        developer.log("Chat object keys: ${(chatJson['chat'] as Map<String, dynamic>).keys.toList()}");
        
        // FIX: Server returns empty ID - use the requested chatId as fallback
        final chatData = chatJson['chat'] as Map<String, dynamic>;
        if (chatData['id'] == null || chatData['id'].toString().trim().isEmpty) {
          developer.log("🔧 FIXING: Server returned empty chat ID, using request ID: $chatId");
          chatData['id'] = chatId;
        }
        
        return Chat.fromJson(chatData);
      }
      return Chat.fromJson(chatJson['chat']);
    } else {
      throw ApiException(
        'Failed to load chat history: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> updateChat(String chatId, ChatUpdateRequest request) async {
    final response = await ApiClient.instance.post(
      '/api/v1/chats/$chatId',
      {'chat': request.toJson()},
    );

    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to update chat: ${response.response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<String> createChat({
    required String title,
    required List<String> models,
  }) async {
    final response = await ApiClient.instance.post(
      '/api/v1/chats/new',
      {
        'chat': {
          'title': title,
          'models': models,
        }
      },
    );

    if (response.statusCode == 200) {
      final responseJson = response.body;
      
      // The ID is at the root of the response object.
      final chatId = responseJson['id'] as String?;

      if (chatId != null && chatId.isNotEmpty) {
        return chatId;
      } else {
        // If the root ID is missing, something is wrong with the server response.
        throw ApiException('Failed to create chat: server response did not include a chat ID.');
      }
    } else {
      throw ApiException(
        'Failed to create chat: ${response.response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  static Future<void> updateChatWithHistory(
    String chatId,
    List<ChatMessage> messages,
    List<String> models,
    String currentId,
  ) async {
    // Build history map for complex chat updates
    final historyMap = <String, dynamic>{};
    
    for (final message in messages) {
      historyMap[message.id] = {
        'id': message.id,
        'parentId': message.parentId,
        'role': message.role,
        'content': message.content,
        'model': message.model,
        'timestamp': message.timestamp?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        'childrenIds': message.childrenIds,
      };
    }
    
    // Update parent-child relationships
    for (final message in messages) {
      if (message.parentId != null && message.parentId!.isNotEmpty) {
        final parentEntry = historyMap[message.parentId!];
        if (parentEntry != null) {
          final childrenIds = List<String>.from(parentEntry['childrenIds']);
          if (!childrenIds.contains(message.id)) {
            childrenIds.add(message.id);
            parentEntry['childrenIds'] = childrenIds;
          }
        }
      }
    }
    
    final payload = {
      'chat': {
        'messages': messages.map((m) => m.toJson()).toList(),
        'models': models,
        'history': {
          'messages': historyMap,
          'currentId': currentId,
        }
      }
    };

    final response = await ApiClient.instance.post('/api/v1/chats/$chatId', payload);
    
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to update chat with history: ${response.response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}
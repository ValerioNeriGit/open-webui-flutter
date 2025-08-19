import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import '../../api_exception.dart';
import '../../endpoints/chats/chat_endpoints.dart';
import '../../endpoints/chats/chat_types.dart';
import '../../endpoints/completions/completion_endpoints.dart';
import '../../endpoints/completions/completion_types.dart';
import 'send_message_types.dart';

class SendMessageApi {
  static const _uuid = Uuid();
  
  /// Complex multi-step API workflow for sending messages
  /// This handles the ill-written backend API that requires 6 steps
  static Future<SendMessageResponse> sendMessage(SendMessageRequest request) async {
    try {
      developer.log('Starting send message workflow for chat: ${request.chatId}');
      
      // Step 1: Prepare messages (internal method)
      final messagePrep = _prepareMessages(request);
      developer.log('Step 1: Messages prepared - user: ${messagePrep.userMessage.id}, assistant: ${messagePrep.assistantPlaceholder.id}');
      
      // Step 2: First update - add user message and placeholder
      await _firstUpdate(request.chatId, messagePrep.updatedMessages, request.model);
      developer.log('Step 2: First update completed');
      
      // Step 3: Get AI completion
      final completion = await _getCompletion(
        request.chatId, 
        messagePrep.updatedMessages, 
        request.model,
        messagePrep.assistantPlaceholder.id
      );
      developer.log('Step 3: AI completion received');
      
      // Step 4: Send completion notification
      await _notifyCompletion(
        request.chatId,
        messagePrep.assistantPlaceholder.id,
        completion.modelUsed,
        messagePrep.updatedMessages
      );
      developer.log('Step 4: Completion notification sent');
      
      // Step 5: Update assistant message with AI content
      final finalMessages = _updateAssistantMessage(
        messagePrep.updatedMessages,
        messagePrep.assistantPlaceholder.id,
        completion.aiContent
      );
      developer.log('Step 5: Assistant message updated');
      
      // Step 6: Final update with complete history
      await _finalUpdate(request.chatId, finalMessages, request.model, messagePrep.assistantPlaceholder.id);
      developer.log('Step 6: Final update with history completed');
      
      return SendMessageResponse(
        aiContent: completion.aiContent,
        updatedMessages: finalMessages,
      );
    } catch (e) {
      developer.log('Error in sendMessage workflow: $e');
      throw ApiException('Send message failed: $e');
    }
  }
  
  /// Step 1: Prepare user message and assistant placeholder
  static MessagePrepResult _prepareMessages(SendMessageRequest request) {
    final lastMessageId = request.currentMessages.isNotEmpty ? request.currentMessages.last.id : "";
    final userMsgId = _uuid.v4();
    final assistantMsgId = _uuid.v4();
    
    final userMessage = ChatMessage(
      id: userMsgId,
      parentId: lastMessageId,
      role: 'user',
      content: request.prompt,
      timestamp: DateTime.now(),
      model: request.model,
      childrenIds: [assistantMsgId],
    );
    
    final assistantPlaceholder = ChatMessage(
      id: assistantMsgId,
      parentId: userMsgId,
      role: 'assistant',
      content: '',
      timestamp: DateTime.now(),
      model: request.model,
    );
    
    final updatedMessages = List<ChatMessage>.from(request.currentMessages)
      ..add(userMessage)
      ..add(assistantPlaceholder);
    
    return MessagePrepResult(
      userMessage: userMessage,
      assistantPlaceholder: assistantPlaceholder,
      updatedMessages: updatedMessages,
    );
  }
  
  /// Step 2: First chat update with user message and placeholder
  static Future<void> _firstUpdate(String chatId, List<ChatMessage> messages, String model) async {
    final updateRequest = ChatUpdateRequest(messages: messages, models: [model]);
    await ChatEndpoints.updateChat(chatId, updateRequest);
  }
  
  /// Step 3: Get AI completion from the model
  static Future<CompletionResponse> _getCompletion(
    String chatId,
    List<ChatMessage> messages,
    String model,
    String assistantId
  ) async {
    final completionRequest = CompletionRequest(
      stream: false,
      model: model,
      messages: messages.map((msg) => {'role': msg.role, 'content': msg.content}).toList(),
      chatId: chatId,
      id: assistantId,
    );
    
    return await CompletionEndpoints.getCompletion(completionRequest);
  }
  
  /// Step 4: Notify the backend that completion is done
  static Future<void> _notifyCompletion(
    String chatId,
    String assistantId,
    String modelUsed,
    List<ChatMessage> messages
  ) async {
    final notificationRequest = CompletionNotificationRequest(
      model: modelUsed,
      messages: messages.map((msg) => {'role': msg.role, 'content': msg.content}).toList(),
      modelItem: {"id": assistantId, "name": modelUsed},
      chatId: chatId,
      id: assistantId,
      sessionId: assistantId,
    );
    
    await CompletionEndpoints.notifyCompletion(notificationRequest);
  }
  
  /// Step 5: Update assistant message with actual AI content
  static List<ChatMessage> _updateAssistantMessage(
    List<ChatMessage> messages,
    String assistantId,
    String aiContent
  ) {
    final index = messages.indexWhere((msg) => msg.id == assistantId);
    if (index == -1) {
      throw ApiException('Assistant message not found with id: $assistantId');
    }
    
    final updatedMessage = messages[index].copyWith(content: aiContent);
    final result = List<ChatMessage>.from(messages);
    result[index] = updatedMessage;
    return result;
  }
  
  /// Step 6: Final update with complete history structure
  static Future<void> _finalUpdate(
    String chatId,
    List<ChatMessage> messages,
    String model,
    String currentId
  ) async {
    await ChatEndpoints.updateChatWithHistory(chatId, messages, [model], currentId);
  }
}
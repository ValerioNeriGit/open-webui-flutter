import '../../../models/chat.dart';

class SendMessageRequest {
  final String chatId;
  final List<ChatMessage> currentMessages;
  final String model;
  final String prompt;
  
  SendMessageRequest({
    required this.chatId,
    required this.currentMessages, 
    required this.model,
    required this.prompt,
  });
}

class SendMessageResponse {
  final String aiContent;
  final List<ChatMessage> updatedMessages;
  
  SendMessageResponse({
    required this.aiContent,
    required this.updatedMessages,
  });
}

// Internal types for the API workflow steps
class MessagePrepResult {
  final ChatMessage userMessage;
  final ChatMessage assistantPlaceholder;
  final List<ChatMessage> updatedMessages;
  
  MessagePrepResult({
    required this.userMessage,
    required this.assistantPlaceholder,
    required this.updatedMessages,
  });
}
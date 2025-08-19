class CompletionRequest {
  final bool stream;
  final String model;
  final List<Map<String, String>> messages;
  final String chatId;
  final String id;
  
  CompletionRequest({
    required this.stream,
    required this.model,
    required this.messages,
    required this.chatId,
    required this.id,
  });
  
  Map<String, dynamic> toJson() => {
    'stream': stream,
    'model': model,
    'messages': messages,
    'chat_id': chatId,
    'id': id,
  };
}

class CompletionResponse {
  final String aiContent;
  final String modelUsed;
  
  CompletionResponse({
    required this.aiContent,
    required this.modelUsed,
  });
  
  factory CompletionResponse.fromJson(Map<String, dynamic> json) {
    return CompletionResponse(
      aiContent: json['choices'][0]['message']['content'],
      modelUsed: json['model'],
    );
  }
}

class CompletionNotificationRequest {
  final String model;
  final List<Map<String, String>> messages;
  final Map<String, dynamic> modelItem;
  final String chatId;
  final String id;
  final String sessionId;
  
  CompletionNotificationRequest({
    required this.model,
    required this.messages,
    required this.modelItem,
    required this.chatId,
    required this.id,
    required this.sessionId,
  });
  
  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages,
    'model_item': modelItem,
    'chat_id': chatId,
    'id': id,
    'session_id': sessionId,
  };
}
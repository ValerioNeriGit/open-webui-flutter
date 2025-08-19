class Message {
  final String id;
  final String sessionId;
  final String? invocationId;
  final String userId;
  Map<String, dynamic> content;
  final String author;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.sessionId,
    this.invocationId,
    required this.userId,
    required this.content,
    required this.author,
    required this.timestamp,
  });

  bool get isUser => author == 'user';
  String get text =>
      (content['parts'] as List).map((p) => p['text'] ?? '').join('');

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sessionId: json['session_id'],
      invocationId: json['invocation_id'],
      userId: json['user_id'],
      content: json['content'] is String
          ? {
              'role': 'model',
              'parts': [
                {'text': json['content']},
              ],
            }
          : json['content'],
      author: json['author'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

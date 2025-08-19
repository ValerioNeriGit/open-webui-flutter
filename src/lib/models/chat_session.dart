class ChatSession {
  final String id;
  final String userId;
  final String appName; // Agent ID
  final DateTime updateTime;

  ChatSession({
    required this.id,
    required this.userId,
    required this.appName,
    required this.updateTime,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      userId: json['user_id'],
      appName: json['app_name'],
      updateTime: DateTime.parse(json['update_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'app_name': appName,
      'update_time': updateTime.toIso8601String(),
    };
  }
}

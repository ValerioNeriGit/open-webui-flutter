import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

// --- Models for API Responses ---

@JsonSerializable(explicitToJson: true)
class ChatListItem {
  final String id;
  final String title;
  @TimestampEpochConverter() @JsonKey(name: 'updated_at') final DateTime? updatedAt;
  @TimestampEpochConverter() @JsonKey(name: 'created_at') final DateTime? createdAt;

  ChatListItem({ required this.id, required this.title, this.updatedAt, this.createdAt });
  factory ChatListItem.fromJson(Map<String, dynamic> json) => _$ChatListItemFromJson(json);
  Map<String, dynamic> toJson() => _$ChatListItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Chat {
  final String id;
  final String title;
  @TimestampEpochConverter() @JsonKey(name: 'updated_at') final DateTime? updatedAt;
  @TimestampEpochConverter() @JsonKey(name: 'created_at') final DateTime? createdAt;
  @JsonKey(defaultValue: []) final List<String> models;
  @JsonKey(defaultValue: []) final List<ChatMessage> messages;
  final History? history;

  Chat({ required this.id, required this.title, this.updatedAt, this.createdAt, required this.models, this.history, this.messages = const [] });
  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChatMessage {
  final String id;
  final String? parentId;
  final String role;
  final String content;
  final String? model;
  @TimestampEpochConverter() final DateTime? timestamp;
  @JsonKey(defaultValue: []) final List<String> childrenIds;

  ChatMessage({ required this.id, this.parentId, required this.role, required this.content, this.model, this.timestamp, this.childrenIds = const [] });
  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({ String? id, String? parentId, String? role, String? content, String? model, DateTime? timestamp, List<String>? childrenIds }) {
    return ChatMessage( id: id ?? this.id, parentId: parentId ?? this.parentId, role: role ?? this.role, content: content ?? this.content, model: model ?? this.model, timestamp: timestamp ?? this.timestamp, childrenIds: childrenIds ?? this.childrenIds );
  }
}

@JsonSerializable(explicitToJson: true)
class History {
  @JsonKey(defaultValue: {}) final Map<String, ChatMessage> messages;
  @JsonKey(name: 'currentId') final String? currentId;

  History({ required this.messages, this.currentId });
  factory History.fromJson(Map<String, dynamic> json) => _$HistoryFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryToJson(this);
}

// --- Models for API Requests ---

@JsonSerializable(explicitToJson: true)
class ChatUpdateRequest {
  final List<ChatMessage> messages;
  final List<String> models;

  ChatUpdateRequest({ required this.messages, required this.models });
  factory ChatUpdateRequest.fromJson(Map<String, dynamic> json) => _$ChatUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUpdateRequestToJson(this);
}


// --- Converters ---

class TimestampEpochConverter implements JsonConverter<DateTime?, int?> {
  const TimestampEpochConverter();
  @override
  DateTime? fromJson(int? json) => json == null ? null : DateTime.fromMillisecondsSinceEpoch(json * 1000);
  @override
  int? toJson(DateTime? object) => object == null ? null : object.millisecondsSinceEpoch ~/ 1000;
}

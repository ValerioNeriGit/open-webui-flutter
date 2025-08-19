// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatListItem _$ChatListItemFromJson(Map<String, dynamic> json) => ChatListItem(
  id: json['id'] as String,
  title: json['title'] as String,
  updatedAt: const TimestampEpochConverter().fromJson(
    (json['updated_at'] as num?)?.toInt(),
  ),
  createdAt: const TimestampEpochConverter().fromJson(
    (json['created_at'] as num?)?.toInt(),
  ),
);

Map<String, dynamic> _$ChatListItemToJson(ChatListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'updated_at': const TimestampEpochConverter().toJson(instance.updatedAt),
      'created_at': const TimestampEpochConverter().toJson(instance.createdAt),
    };

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
  id: json['id'] as String,
  title: json['title'] as String,
  updatedAt: const TimestampEpochConverter().fromJson(
    (json['updated_at'] as num?)?.toInt(),
  ),
  createdAt: const TimestampEpochConverter().fromJson(
    (json['created_at'] as num?)?.toInt(),
  ),
  models:
      (json['models'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  history: json['history'] == null
      ? null
      : History.fromJson(json['history'] as Map<String, dynamic>),
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'updated_at': const TimestampEpochConverter().toJson(instance.updatedAt),
  'created_at': const TimestampEpochConverter().toJson(instance.createdAt),
  'models': instance.models,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
  'history': instance.history?.toJson(),
};

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: json['id'] as String,
  parentId: json['parentId'] as String?,
  role: json['role'] as String,
  content: json['content'] as String,
  model: json['model'] as String?,
  timestamp: const TimestampEpochConverter().fromJson(
    (json['timestamp'] as num?)?.toInt(),
  ),
  childrenIds:
      (json['childrenIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'role': instance.role,
      'content': instance.content,
      'model': instance.model,
      'timestamp': const TimestampEpochConverter().toJson(instance.timestamp),
      'childrenIds': instance.childrenIds,
    };

History _$HistoryFromJson(Map<String, dynamic> json) => History(
  messages:
      (json['messages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, ChatMessage.fromJson(e as Map<String, dynamic>)),
      ) ??
      {},
  currentId: json['currentId'] as String?,
);

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
  'messages': instance.messages.map((k, e) => MapEntry(k, e.toJson())),
  'currentId': instance.currentId,
};

ChatUpdateRequest _$ChatUpdateRequestFromJson(Map<String, dynamic> json) =>
    ChatUpdateRequest(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      models: (json['models'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ChatUpdateRequestToJson(ChatUpdateRequest instance) =>
    <String, dynamic>{
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'models': instance.models,
    };

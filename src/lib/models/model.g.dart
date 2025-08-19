// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
  id: json['id'] as String,
  name: json['name'] as String,
  object: json['object'] as String,
  created: (json['created'] as num?)?.toInt(),
  ownedBy: json['owned_by'] as String,
);

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'object': instance.object,
  'created': instance.created,
  'owned_by': instance.ownedBy,
};

ModelListResponse _$ModelListResponseFromJson(Map<String, dynamic> json) =>
    ModelListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => Model.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModelListResponseToJson(ModelListResponse instance) =>
    <String, dynamic>{'data': instance.data};

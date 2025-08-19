import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Model {
  final String id;
  final String name;
  final String object;
  final int? created;
  @JsonKey(name: 'owned_by')
  final String ownedBy;

  Model({
    required this.id,
    required this.name,
    required this.object,
    this.created,
    required this.ownedBy,
  });

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);
  Map<String, dynamic> toJson() => _$ModelToJson(this);
}

@JsonSerializable()
class ModelListResponse {
  final List<Model> data;

  ModelListResponse({required this.data});

  factory ModelListResponse.fromJson(Map<String, dynamic> json) =>
      _$ModelListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ModelListResponseToJson(this);
}

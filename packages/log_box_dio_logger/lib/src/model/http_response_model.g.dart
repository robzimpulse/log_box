// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpResponseModel _$HttpResponseModelFromJson(Map<String, dynamic> json) =>
    HttpResponseModel(
      status: (json['status'] as num?)?.toInt(),
      size: (json['size'] as num).toInt(),
      time: DateTime.parse(json['time'] as String),
      body: json['body'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$HttpResponseModelToJson(HttpResponseModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'size': instance.size,
      'time': instance.time.toIso8601String(),
      'body': instance.body,
      'headers': instance.headers,
    };

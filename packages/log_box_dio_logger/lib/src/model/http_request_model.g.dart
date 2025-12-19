// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpRequestModel _$HttpRequestModelFromJson(
  Map<String, dynamic> json,
) => HttpRequestModel(
  size: (json['size'] as num).toInt(),
  time: DateTime.parse(json['time'] as String),
  headers: json['headers'] as Map<String, dynamic>?,
  body: json['body'] as String?,
  contentType: json['content_type'] as String?,
  cookies: (json['cookies'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  queryParameters: json['query_parameters'] as Map<String, dynamic>,
  formDataFiles:
      (json['form_data_files'] as List<dynamic>?)
          ?.map((e) => FormDataFileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
  formDataFields:
      (json['form_data_fields'] as List<dynamic>?)
          ?.map((e) => FormDataFieldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$HttpRequestModelToJson(
  HttpRequestModel instance,
) => <String, dynamic>{
  'size': instance.size,
  'time': instance.time.toIso8601String(),
  'headers': instance.headers,
  'body': instance.body,
  'content_type': instance.contentType,
  'cookies': instance.cookies,
  'query_parameters': instance.queryParameters,
  'form_data_files': instance.formDataFiles?.map((e) => e.toJson()).toList(),
  'form_data_fields': instance.formDataFields?.map((e) => e.toJson()).toList(),
};

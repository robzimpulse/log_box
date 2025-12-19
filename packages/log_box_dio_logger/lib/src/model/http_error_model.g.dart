// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_error_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HttpErrorModel _$HttpErrorModelFromJson(Map<String, dynamic> json) =>
    HttpErrorModel(
      error: json['error'] as String?,
      stackTrace: json['stack_trace'] as String?,
    );

Map<String, dynamic> _$HttpErrorModelToJson(HttpErrorModel instance) =>
    <String, dynamic>{
      'error': instance.error,
      'stack_trace': instance.stackTrace,
    };

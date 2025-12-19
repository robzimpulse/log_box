// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_data_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormDataFileModel _$FormDataFileModelFromJson(Map<String, dynamic> json) =>
    FormDataFileModel(
      fileName: json['file_name'] as String?,
      contentType: json['content_type'] as String,
      length: (json['length'] as num).toInt(),
    );

Map<String, dynamic> _$FormDataFileModelToJson(FormDataFileModel instance) =>
    <String, dynamic>{
      'file_name': instance.fileName,
      'content_type': instance.contentType,
      'length': instance.length,
    };

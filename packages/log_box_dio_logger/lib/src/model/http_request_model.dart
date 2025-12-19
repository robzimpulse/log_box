import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'form_data_field_model.dart';
import 'form_data_file_model.dart';

part 'http_request_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class HttpRequestModel extends Equatable {
  factory HttpRequestModel.create({
    int size = 0,
    Map<String, dynamic>? headers,
    String? body,
    String? contentType,
    Map<String, String> cookies = const {},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    List<FormDataFileModel>? formDataFiles,
    List<FormDataFieldModel>? formDataFields,
  }) {
    return HttpRequestModel(
      size: size,
      time: DateTime.timestamp(),
      headers: headers,
      body: body,
      contentType: contentType,
      cookies: cookies,
      queryParameters: queryParameters,
      formDataFiles: formDataFiles,
      formDataFields: formDataFields,
    );
  }

  const HttpRequestModel({
    required this.size,
    required this.time,
    this.headers,
    this.body,
    this.contentType,
    required this.cookies,
    required this.queryParameters,
    this.formDataFiles,
    this.formDataFields,
  });

  final int size;
  final DateTime time;
  final Map<String, dynamic>? headers;
  final String? body;
  final String? contentType;
  final Map<String, String>? cookies;
  final Map<String, dynamic> queryParameters;
  final List<FormDataFileModel>? formDataFiles;
  final List<FormDataFieldModel>? formDataFields;

  Map<String, dynamic> toJson() => _$HttpRequestModelToJson(this);

  factory HttpRequestModel.fromJson(Map<String, dynamic> json) {
    return _$HttpRequestModelFromJson(json);
  }

  @override
  List<Object?> get props => [
    size,
    time,
    headers,
    body,
    contentType,
    cookies,
    queryParameters,
    formDataFiles,
    formDataFields,
  ];

  HttpRequestModel copyWith({
    int? size,
    Map<String, dynamic>? headers,
    String? body,
    String? contentType,
    Map<String, String>? cookies,
    Map<String, dynamic>? queryParameters,
    List<FormDataFileModel>? formDataFiles,
    List<FormDataFieldModel>? formDataFields,
  }) {
    return HttpRequestModel(
      size: size ?? this.size,
      time: time,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      contentType: contentType ?? this.contentType,
      cookies: cookies ?? this.cookies,
      queryParameters: queryParameters ?? this.queryParameters,
      formDataFiles: formDataFiles ?? this.formDataFiles,
      formDataFields: formDataFields ?? this.formDataFields,
    );
  }
}
import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'http_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class HttpResponseModel extends Equatable {
  factory HttpResponseModel.create({
    int? status,
    int size = 0,
    String? body,
    Map<String, List<String>>? headers,
  }) {
    return HttpResponseModel(
      status: status,
      size: size,
      time: DateTime.timestamp(),
      body: body,
      headers: headers,
    );
  }

  const HttpResponseModel({
    this.status,
    required this.size,
    required this.time,
    this.body,
    this.headers,
  });

  Map<String, dynamic> toJson() => _$HttpResponseModelToJson(this);

  factory HttpResponseModel.fromJson(Map<String, dynamic> json) {
    return _$HttpResponseModelFromJson(json);
  }

  final int? status;
  final int size;
  final DateTime time;
  final String? body;
  final Map<String, List<String>>? headers;

  @override
  List<Object?> get props => [status, size, time, body, headers];

  Uint8List? get image {
    final body = this.body;
    if (body == null || body.isEmpty) return null;
    try {
      return Uint8List.fromList(List.from(json.decode(body)));
    } catch (e) {
      return null;
    }
  }
}

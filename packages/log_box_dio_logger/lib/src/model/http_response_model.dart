import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:universal_io/io.dart';

class HttpResponseModel extends Equatable {
  factory HttpResponseModel.create({
    int? status,
    int size = 0,
    String? body,
    Map<String, List<String>>? headers,
  }) {
    return HttpResponseModel._(
      status: status,
      size: size,
      time: DateTime.timestamp(),
      body: body,
      headers: headers,
    );
  }

  const HttpResponseModel._({
    this.status,
    required this.size,
    required this.time,
    this.body,
    this.headers,
  });

  final int? status;
  final int size;
  final DateTime time;
  final String? body;
  final Map<String, List<String>>? headers;

  @override
  List<Object?> get props => [status, size, time, body, headers];

  bool get isImage {
    final result = headers?[HttpHeaders.contentTypeHeader]
        ?.map((e) => e.contains(RegExp(r'image/.*')))
        .contains(true);

    return result ?? false;
  }

  Uint8List? get image {
    final body = this.body;
    if (body == null || body.isEmpty) return null;
    return Uint8List.fromList(List.from(json.decode(body)));
  }
}

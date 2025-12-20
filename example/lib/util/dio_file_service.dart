import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dio_get_response.dart';

class DioFileService extends FileService {
  final ValueGetter<Dio> dio;

  DioFileService({required this.dio});

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return DioGetResponse(
      await dio().get<ResponseBody>(
        url,
        options: Options(
          headers: headers ?? {},
          responseType: ResponseType.stream,
        ),
      ),
    );
  }
}

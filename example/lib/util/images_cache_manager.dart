import 'package:dio/dio.dart';
import 'package:example/util/dio_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImagesCacheManager extends CacheManager with ImageCacheManager {
  final ValueGetter<Dio> dio;

  ImagesCacheManager({required this.dio})
    : super(Config('images', fileService: DioFileService(dio: dio)));
}

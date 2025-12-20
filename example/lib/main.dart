import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';

import 'screen/app_screen.dart';
import 'util/images_cache_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final box = LogBox(capacity: 100);
  final dio = Dio()..interceptors.add(box.interceptor);
  final cache = ImagesCacheManager(dio: () => dio);
  runApp(AppScreen(box: box, dio: dio, cache: cache));
}

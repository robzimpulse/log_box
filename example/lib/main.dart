import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';

import 'screen/app_screen.dart';
import 'util/images_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final box = LogBox();
  final dio = Dio()..interceptors.add(box.interceptor);
  final cache = ImagesCacheManager(dio: () => dio);

  Future.delayed(Duration(seconds: 5), () async {
    for (final log in List.generate(10000, (e) => e)) {
      await Future.delayed(Duration(microseconds: 500));
      box.log('Testing message with index $log');
    }
  });

  runApp(AppScreen(box: box, dio: dio, cache: cache));
}

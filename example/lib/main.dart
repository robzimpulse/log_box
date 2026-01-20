import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';
import 'package:log_box_persistent_storage_drift/log_box_persistent_storage_drift.dart';

import 'screen/app_screen.dart';
import 'util/images_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final box = LogBox(
    storage: Storage(
      liveDataStorage: MemoryStorage(capacity: 10),
      persistentDataStorage: DriftPersistentStorage(
        executor: MemoryExecutor(),
        decoder: {
          (LogEntryModel).toString(): LogEntryModel.fromJson,
          (WebviewEntryModel).toString(): WebviewEntryModel.fromJson,
          (NavigationEntryModel).toString(): NavigationEntryModel.fromJson,
          (TraceLogEntryModel).toString(): TraceLogEntryModel.fromJson,
          (NetworkEntryModel).toString(): NetworkEntryModel.fromJson,
        },
      ),
    ),
  );
  final dio = Dio()..interceptors.add(box.interceptor);
  final cache = ImagesCacheManager(dio: () => dio);
  Future.delayed(Duration(seconds: 5), () async {
    for (final log in List.generate(50, (e) => e)) {
      await Future.delayed(Duration(microseconds: 500));
      box.log('Testing message with index $log');
    }

    Future.delayed(Duration(seconds: 5), () async {
      for (final log in List.generate(1000, (e) => e)) {
        await Future.delayed(Duration(microseconds: 500));
        box.log('Testing message with index $log');
      }
    });
  });

  runApp(AppScreen(box: box, dio: dio, cache: cache));
}

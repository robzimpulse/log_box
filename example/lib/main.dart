import 'package:dio/dio.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';
import 'package:log_box_file_storage/log_box_file_storage.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';
import 'package:path_provider/path_provider.dart';

import 'screen/app_screen.dart';
import 'util/images_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = await getTemporaryDirectory();
  final storage = await FileStorage.create(
    root: LocalFileSystem().directory('${path.path}/log_box_example'),
    coder: {
      '$LogEntryModel': LogEntryModel.fromJson,
      '$NetworkEntryModel': NetworkEntryModel.fromJson,
      '$TraceLogEntryModel': TraceLogEntryModel.fromJson,
      '$NavigationEntryModel': NavigationEntryModel.fromJson,
      '$WebviewEntryModel': WebviewEntryModel.fromJson,
    },
  );
  final box = LogBox(storage: storage);
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

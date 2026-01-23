import 'dart:io';

import 'package:log_box_persistent_storage_drift/memory_executor.dart';
import 'package:path_provider/path_provider.dart';

import '../../database/executor/base.dart';
import '../../database/executor/file_executor.dart';

Future<Executor> getExecutor() async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return MemoryExecutor();
  }
  return getApplicationDocumentsDirectory().then(
    (e) => FileExecutor(path: e.path),
  );
}

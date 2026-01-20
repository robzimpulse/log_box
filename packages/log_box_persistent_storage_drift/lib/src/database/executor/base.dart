import 'package:drift/drift.dart';

import '../../adapter/executor_adapter/executor_adapter.dart'
    if (dart.library.js_interop) '../../adapter/executor_adapter/executor_adapter_web.dart'
    if (dart.library.io) '../../adapter/executor_adapter/executor_adapter_io.dart';

abstract class Executor {
  QueryExecutor get executor;

  static Future<Executor> adaptive() => getExecutor();
}

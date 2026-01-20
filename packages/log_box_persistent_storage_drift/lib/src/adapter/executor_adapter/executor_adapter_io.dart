import 'package:path_provider/path_provider.dart';

import '../../database/executor/base.dart';
import '../../database/executor/file_executor.dart';

Future<Executor> getExecutor() async {
  return getApplicationSupportDirectory().then(
    (e) => FileExecutor(path: e.path),
  );
}

import '../../database/executor/base.dart';
import '../../database/executor/file_executor.dart';

Future<Executor> getExecutor() async {
  return FileExecutor(path: '');
}
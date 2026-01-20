import '../../database/executor/base.dart';
import '../../database/executor/memory_executor.dart';

Future<Executor> getExecutor() async {
  return MemoryExecutor();
}
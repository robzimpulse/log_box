import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'src/database/executor/base.dart';

class MemoryExecutor extends Executor {
  final QueryExecutor _executor;

  MemoryExecutor({QueryExecutor? executor})
    : _executor =
          executor ??
          DatabaseConnection(
            NativeDatabase.memory(),
            closeStreamsSynchronously: true,
          );

  @override
  QueryExecutor get executor => _executor;
}

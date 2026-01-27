import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_persistent_storage_drift/src/model/drift_query_entry_model.dart';

class DriftQueryInterceptor extends QueryInterceptor {
  final Storage _storage;

  DriftQueryInterceptor({required Storage storage}) : _storage = storage;

  Future<T> _run<T>({
    required String description,
    String? statement,
    List<Object?>? args,
    required FutureOr<T> Function() operation,
  }) async {
    final stopwatch = Stopwatch()..start();
    var model = DriftQueryEntryModel(
      operation: description,
      statement: statement,
      arguments: Map.fromEntries([
        ...?args?.mapIndexed((i, e) => MapEntry('$i', e.toString())),
      ]),
    );
    try {
      return await operation();
    } catch (e, st) {
      model = model.copyWith(error: e.toString(), stackTrace: st.toString());
      rethrow;
    } finally {
      _storage.add(log: model.copyWith(duration: stopwatch.elapsed));
      stopwatch.stop();
    }
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    _storage.add(log: DriftQueryEntryModel(operation: 'Begin'));
    return super.beginTransaction(parent);
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    return _run(description: 'Commit', operation: () => inner.send());
  }

  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) {
    return _run(description: 'Rollback', operation: () => inner.rollback());
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) {
    return _run(
      description: 'Batch',
      statement: statements.toString(),
      operation: () => executor.runBatched(statements),
    );
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Insert',
      statement: statement,
      args: args,
      operation: () => executor.runInsert(statement, args),
    );
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Update',
      statement: statement,
      args: args,
      operation: () => executor.runUpdate(statement, args),
    );
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Delete',
      statement: statement,
      args: args,
      operation: () => executor.runDelete(statement, args),
    );
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Custom',
      statement: statement,
      args: args,
      operation: () => executor.runCustom(statement, args),
    );
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      description: 'Select',
      statement: statement,
      args: args,
      operation: () => executor.runSelect(statement, args),
    );
  }
}

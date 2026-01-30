import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:log_box/log_box.dart';

import '../model/drift_query_entry_model.dart';
import '../model/drift_query_operation_model.dart';
import '../extension/string_format_extension.dart';

enum DatabaseOperation {
  beginTransaction('Begin Transaction'),
  commitTransaction('Commit Transaction'),
  rollbackTransaction('Rollback Transaction'),
  runBatched('Batched'),
  runCustom('Custom'),
  runDelete('Delete'),
  runInsert('Insert'),
  runSelect('Select'),
  runUpdate('Update');

  final String rawValue;

  const DatabaseOperation(this.rawValue);
}

class DriftQueryInterceptor extends QueryInterceptor {
  final Storage _storage;

  DriftQueryInterceptor({required Storage storage}) : _storage = storage;

  void _add({
    required DatabaseOperation operation,
    required DriftQueryOperationModel model,
  }) {
    print('Operation: ${operation.rawValue}: ${model.statements.length}');

    // TODO: implement this
    // final value = model.copyWith(operation: operation.rawValue);
    // _current = (_current ?? DriftQueryEntryModel()).copyWith(
    //   operations: [model.copyWith(operation: operation.rawValue)],
    // );
    // switch (operation) {
    //   case DatabaseOperation.beginTransaction:
    //     if (_stack.isEmpty) {
    //       _stack.add(value);
    //     } else {
    //       _storage.add(log: DriftQueryEntryModel(operations: _stack));
    //       _stack.clear();
    //       _stack.add(value);
    //     }
    //
    //   case DatabaseOperation.commitTransaction:
    //     if (_stack.isEmpty) {
    //     } else {}
    //
    //   case DatabaseOperation.rollbackTransaction:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case DatabaseOperation.runBatched:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case DatabaseOperation.runCustom:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case DatabaseOperation.runDelete:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case DatabaseOperation.runInsert:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case DatabaseOperation.runSelect:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    //   case DatabaseOperation.runUpdate:
    //     // TODO: Handle this case.
    //     throw UnimplementedError();
    // }
  }

  Future<T> _runFuture<T>({
    required DatabaseOperation type,
    List<String> statements = const [],
    required Future<T> Function() operation,
  }) async {
    final stopwatch = Stopwatch()..start();
    var model = DriftQueryOperationModel.create(statements: statements);
    try {
      return await operation();
    } catch (e, st) {
      model = model.copyWith(error: e.toString(), stackTrace: st.toString());
      rethrow;
    } finally {
      _add(
        operation: type,
        model: model.copyWith(duration: stopwatch.elapsed),
      );
      stopwatch.stop();
    }
  }

  T _run<T>({
    required DatabaseOperation type,
    required T Function() operation,
  }) {
    final stopwatch = Stopwatch()..start();
    var model = DriftQueryOperationModel.create();
    try {
      return operation();
    } catch (e, st) {
      model = model.copyWith(error: e.toString(), stackTrace: st.toString());
      rethrow;
    } finally {
      _add(
        operation: type,
        model: model.copyWith(duration: stopwatch.elapsed),
      );
      stopwatch.stop();
    }
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    return _run(
      type: DatabaseOperation.beginTransaction,
      operation: () => parent.beginTransaction(),
    );
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    return _runFuture(
      type: DatabaseOperation.commitTransaction,
      operation: () => inner.send(),
    );
  }

  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) {
    return _runFuture(
      type: DatabaseOperation.rollbackTransaction,
      operation: () => inner.rollback(),
    );
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) {
    return _runFuture(
      type: DatabaseOperation.runBatched,
      statements: [
        for (final (index, statement) in statements.statements.indexed)
          statement.interpolate(
            statements.arguments
                .firstWhereOrNull((e) => e.statementIndex == index)
                ?.arguments,
          ),
      ],
      operation: () => executor.runBatched(statements),
    );
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _runFuture(
      type: DatabaseOperation.runInsert,
      statements: [statement.interpolate(args)],
      operation: () => executor.runInsert(statement, args),
    );
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _runFuture(
      type: DatabaseOperation.runUpdate,
      statements: [statement.interpolate(args)],
      operation: () => executor.runUpdate(statement, args),
    );
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _runFuture(
      type: DatabaseOperation.runDelete,
      statements: [statement.interpolate(args)],
      operation: () => executor.runDelete(statement, args),
    );
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _runFuture(
      type: DatabaseOperation.runCustom,
      statements: [statement.interpolate(args)],
      operation: () => executor.runCustom(statement, args),
    );
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _runFuture(
      type: DatabaseOperation.runSelect,
      statements: [statement.interpolate(args)],
      operation: () => executor.runSelect(statement, args),
    );
  }
}

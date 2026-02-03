import 'dart:async';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../enum/database_operation.dart';
import '../model/drift_query_operation_model.dart';
import '../extension/string_format_extension.dart';

class DriftQueryInterceptor extends QueryInterceptor {
  final ValueSetter<DriftQueryOperationModel>? _onEvent;

  DriftQueryInterceptor({ValueSetter<DriftQueryOperationModel>? onEvent})
    : _onEvent = onEvent;

  Future<T> _runFuture<T>({
    required DatabaseOperation type,
    List<String> statements = const [],
    required Future<T> Function() operation,
  }) async {
    final stopwatch = Stopwatch()..start();
    var model = DriftQueryOperationModel.create(
      operation: type,
      statements: statements,
    );
    try {
      return await operation();
    } catch (e, st) {
      model = model.copyWith(error: e.toString(), stackTrace: st.toString());
      rethrow;
    } finally {
      _onEvent?.call(model.copyWith(duration: stopwatch.elapsed));
      stopwatch.stop();
    }
  }

  T _run<T>({
    required DatabaseOperation type,
    required T Function() operation,
  }) {
    final stopwatch = Stopwatch()..start();
    var model = DriftQueryOperationModel.create(operation: type);
    try {
      return operation();
    } catch (e, st) {
      model = model.copyWith(error: e.toString(), stackTrace: st.toString());
      rethrow;
    } finally {
      _onEvent?.call(model.copyWith(duration: stopwatch.elapsed));
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

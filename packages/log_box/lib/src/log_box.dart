import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'model/log_entry_model.dart';
import 'model/trace_log_entry_model.dart';
import 'storage/storage.dart';
import 'storage/memory_storage.dart';

class LogBox {
  final Storage storage;

  // variable for storing known routes
  Map<String, RouteSettings> routes = {};

  LogBox({required int capacity}) : storage = MemoryStorage(capacity: capacity);

  FutureOr<T> tracer<T>(
    String name,
    FutureOr<T> Function(ValueSetter<LogEntryModel> trace) process,
  ) async {
    final id = Uuid().v4();

    storage.add(
      log: TraceLogEntryModel(
        id: id,
        name: name,
        logs: [LogEntryModel(message: 'Start')],
      ),
    );

    final result = await process((log) {
      storage.add(log: TraceLogEntryModel(id: id, name: name, logs: [log]));
    });

    storage.add(
      log: TraceLogEntryModel(
        id: id,
        name: name,
        logs: [LogEntryModel(message: 'Finish')],
      ),
    );

    return result;
  }

  void log(
    String message, {
    String? id,
    Map<String, dynamic>? extra,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    storage.add(
      log: LogEntryModel(
        id: id,
        name: name,
        message: message,
        extra: extra ?? {},
        error: error?.toString(),
        stackTrace: stackTrace?.toString(),
      ),
    );

    dev.log(message, name: name ?? '', error: error, stackTrace: stackTrace);
  }
}

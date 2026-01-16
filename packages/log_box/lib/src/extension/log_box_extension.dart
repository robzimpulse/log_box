import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../log_box.dart';

extension LogBoxExtension on LogBox {
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

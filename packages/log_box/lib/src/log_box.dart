import 'dart:async';
import 'dart:developer' as dev;

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box/src/model/trace_log_entry_model.dart';
import 'package:uuid/uuid.dart';

import 'screen/dashboard_screen.dart';
import 'screen/detail_screen.dart';

class LogBox {
  final Storage storage;

  // variable for storing known routes
  Map<String, RouteSettings> routes = {};

  LogBox({List<StorageDecoder> codec = const [], required Directory root})
    : storage = Storage(
        codec: {
          ...StorageDecoder().codec,
          for (final coder in codec) ...coder.codec,
        },
        root: root,
      );

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

  void dashboard({required BuildContext context, ThemeData? theme}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: routes.putIfAbsent(
          'dashboard_route',
          () => const RouteSettings(name: 'logbox/dashboard'),
        ),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: DashboardScreen(
              storage: storage,
              onTap: (item, keyword) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: routes.putIfAbsent(
                      'detail_route',
                      () => const RouteSettings(name: 'logbox/details'),
                    ),
                    builder: (context) {
                      return DetailScreen(
                        data: item,
                        box: this,
                        keyword: keyword,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

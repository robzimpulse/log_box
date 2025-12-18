import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:log_box/src/model/trace_log_entry_model.dart';
import 'package:log_box/src/storage/storage.dart';
import 'package:uuid/uuid.dart';

import 'model/log_entry_model.dart';
import 'screen/dashboard_screen.dart';
import 'screen/detail_screen.dart';

class LogBox {
  final Storage storage;

  // variable for storing known routes
  Map<String, RouteSettings> routes = {};

  LogBox({required int capacity}) : storage = Storage(capacity: capacity);

  FutureOr tracer<FutureOr>(
    String name,
    FutureOr Function(ValueSetter<LogEntryModel> trace) process,
  ) {
    final id = Uuid().v4();

    storage.add(log: TraceLogEntryModel(id: id, name: name));

    return process.call((log) {
      storage.add(log: TraceLogEntryModel(id: id, name: name, logs: [log]));
    });
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
        error: error,
        stackTrace: stackTrace,
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

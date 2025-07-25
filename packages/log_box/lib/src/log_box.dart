import 'package:flutter/material.dart';
import 'package:log_box/src/model/log_entry_model.dart';
import 'package:log_box/src/storage/storage.dart';

import 'screen/dashboard_screen.dart';
import 'screen/detail_screen.dart';

class LogBox {
  final Storage storage;
  final dashboardRouteName = const RouteSettings(name: 'Log Box Dashboard');
  final detailRouteName = const RouteSettings(name: 'Log Box Detail');

  LogBox({required int capacity}) : storage = Storage(capacity: capacity);

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
  }

  void dashboard({required BuildContext context, ThemeData? theme}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: dashboardRouteName,
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: DashboardScreen(
              storage: storage,
              onTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: detailRouteName,
                    builder: (context) => DetailScreen(data: item),
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

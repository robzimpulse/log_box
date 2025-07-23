import 'package:flutter/material.dart';
import 'package:log_box/src/model/log_entry_model.dart';
import 'package:log_box/src/storage/storage.dart';

import 'src/screen/dashboard_screen.dart';

class LogBox {
  static final LogBox _instance = LogBox._();
  final _storage = Storage(capacity: 1000);
  factory LogBox() => _instance;
  LogBox._();

  final _dashboardRouteName = const RouteSettings(name: 'Log Box Dashboard');

  void log(
    String message, {
    String? id,
    Map<String, dynamic>? extra,
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _storage.add(
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
        settings: _dashboardRouteName,
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: DashboardScreen(storage: _storage),
          );
        },
      ),
    );
  }

}

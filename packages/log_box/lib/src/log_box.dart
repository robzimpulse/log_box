
import 'package:flutter/material.dart';

import 'storage/storage.dart';
import 'storage/memory_storage.dart';

class LogBox {
  final Storage storage;

  // variable for storing known routes
  Map<String, RouteSettings> routes = {};

  LogBox({Storage? storage})
    : storage = storage ?? Storage(liveDataStorage: MemoryStorage());

  void dispose() {
    storage.dispose();
  }
}

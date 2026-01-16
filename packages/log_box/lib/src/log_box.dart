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

  LogBox({Storage? storage})
    : storage = storage ?? MemoryStorage(capacity: 10000);
}

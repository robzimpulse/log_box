import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/entry_model.dart';

class Storage with ChangeNotifier {
  /// Handle mapping between data and id
  final LinkedHashMap<String, EntryModel> _logs;

  /// max capacity of this storage
  final int _capacity;

  Storage({required int capacity})
    : _logs = LinkedHashMap(),
      _capacity = capacity;

  Map<String, EntryModel> get data => _logs;

  void add({required EntryModel log}) {
    _logs.update(log.id, (old) => old.merge(log), ifAbsent: () => log);

    if (_logs.keys.length > _capacity) {
      _logs.remove(_logs.keys.firstOrNull);
    }

    Future.microtask(() => notifyListeners());
  }

  void clear() {
    _logs.clear();
    Future.microtask(() => notifyListeners());
  }

  Map<String, Type> get types {
    return _logs.map(
      (key, value) => MapEntry(value.display(), value.runtimeType),
    );
  }
}

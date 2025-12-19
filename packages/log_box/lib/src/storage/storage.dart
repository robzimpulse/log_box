import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/entry_model.dart';

class Storage with ChangeNotifier {
  /// Handle mapping between data and id
  final LinkedHashMap<String, EntryModel> _logs;

  /// Max capacity of this storage
  final int _capacity;

  /// Callback when data being deleted caused by over capacity
  final ValueSetter<EntryModel>? _onDelete;

  Storage({required int capacity, ValueSetter<EntryModel>? onDelete})
    : _logs = LinkedHashMap(),
      _capacity = capacity,
      _onDelete = onDelete;

  Map<String, EntryModel> get data => _logs;

  void add({required EntryModel log}) {
    _logs.update(log.id, (old) => old.merge(log), ifAbsent: () => log);

    if (_logs.keys.length > _capacity) {
      final key = _logs.keys.firstOrNull;
      if (key != null) {
        final deleted = _logs.remove(key);
        if (deleted != null) _onDelete?.call(deleted);
      }
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

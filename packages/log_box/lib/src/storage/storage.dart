import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/entry_model.dart';

class Storage with ChangeNotifier {
  /// Handle mapping between data and id
  final LinkedHashMap<String, EntryModel> _logs;

  /// Max capacity of this storage
  final int _capacity;

  /// Callback when data being deleted caused by over capacity or clearing data
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
      if (key != null) _remove(key);
    }

    Future.microtask(() => notifyListeners());
  }

  void clear() {
    for (final key in _logs.keys) {
      _remove(key);
    }
    Future.microtask(() => notifyListeners());
  }

  Map<String, Type> get types {
    return _logs.map(
      (key, value) => MapEntry(value.display(), value.runtimeType),
    );
  }

  void _remove(String id) {
    final deleted = _logs.remove(id);
    if (deleted != null) _onDelete?.call(deleted);
  }
}

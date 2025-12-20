import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../model/entry_model.dart';
import 'storage.dart';

class MemoryStorage with ChangeNotifier implements Storage {
  /// Handle mapping between data and id
  final LinkedHashMap<String, EntryModel> _logs;

  final int _capacity;

  final StreamController<EntryModel> _controller;

  Stream<EntryModel> get onDeleteEntry => _controller.stream;

  MemoryStorage({int capacity = 1000})
    : _logs = LinkedHashMap(),
      _capacity = capacity,
      _controller = StreamController();

  @override
  Map<String, EntryModel> get data => _logs;

  @override
  void add({required EntryModel log}) {
    _logs.update(log.id, (old) => old.merge(log), ifAbsent: () => log);
    if (_logs.keys.length > _capacity) {
      final key = _logs.keys.firstOrNull;
      if (key != null) {
        final deleted = _logs.remove(key);
        if (deleted != null) _controller.add(deleted);
      }
    }

    Future.microtask(() => notifyListeners());
  }

  @override
  void clear() {
    _logs.values.forEach(_controller.add);
    _logs.clear();
    Future.microtask(() => notifyListeners());
  }

  @override
  Map<String, Type> get types {
    return _logs.map((k, v) => MapEntry(v.display(), v.runtimeType));
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../model/entry_model.dart';
import 'base/live_data_storage.dart';

class MemoryStorage with ChangeNotifier implements LiveDataStorage {
  final LinkedHashMap<String, EntryModel> _logs;
  final int _capacity;
  final StreamController<EntryModel> _controller;
  bool _isDisposed = false;

  MemoryStorage({int capacity = 1000})
    : _logs = LinkedHashMap(),
      _capacity = capacity,
      _controller = StreamController();

  @override
  void add({required EntryModel log}) {
    if (_isDisposed) {
      throw StateError('MemoryStorage was used after being disposed.');
    }
    _logs.update(log.id, (old) => old.merge(log), ifAbsent: () => log);
    if (_logs.keys.length > _capacity) {
      final key = _logs.keys.firstOrNull;
      if (key != null) {
        final deleted = _logs.remove(key);
        if (deleted != null) _controller.add(deleted);
      }
    }

    notifyListeners();
  }

  @override
  void clear() {
    if (_isDisposed) {
      throw StateError('MemoryStorage was used after being disposed.');
    }
    _logs.values.forEach(_controller.add);
    _logs.clear();
    notifyListeners();
  }

  @override
  List<EntryModel> get data => [..._logs.values];

  @override
  Map<String, Type> get types {
    return _logs.map((k, v) => MapEntry(v.display(), v.runtimeType));
  }

  @override
  Stream<EntryModel> get onDeleteEntry => _controller.stream;

  @override
  void dispose() {
    _isDisposed = true;
    _controller.close();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    Future.microtask(() {
      if (_isDisposed) return;
      super.notifyListeners();
    });
  }
}

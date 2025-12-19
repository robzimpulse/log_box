import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/entry_model.dart';

typedef ToEntry = EntryModel Function(Map<String, dynamic> json);

typedef StorageCodec = Map<Type, ToEntry>;

class Storage with ChangeNotifier {
  /// Handle mapping between data and id
  final LinkedHashMap<String, EntryModel> _logs;

  /// Max capacity of this storage
  final int _capacity;

  /// Codec for decoding data [EntryModel] from storage

  final StorageCodec _codec;

  Storage({required int capacity, StorageCodec codec = const {}})
    : _logs = LinkedHashMap(),
      _codec = codec,
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
    return _logs.map((k, v) => MapEntry(v.display(), v.runtimeType));
  }
}

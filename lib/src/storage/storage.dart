import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../model/entry_model.dart';

final class _Identifier extends LinkedListEntry<_Identifier> {
  String value;

  _Identifier(this.value);

  @override
  String toString() => value;
}

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

    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }

  Set<Type> get types => {..._logs.values.map((e) => e.runtimeType)};
}

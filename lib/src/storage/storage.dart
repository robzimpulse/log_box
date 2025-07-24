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
  Map<String, EntryModel> _logs;

  /// Ids reference to track insert order
  final LinkedList<_Identifier> _ids;

  /// max capacity of this storage
  final int _capacity;

  Storage({required int capacity})
    : _logs = {},
      _ids = LinkedList(),
      _capacity = capacity;

  Map<String, EntryModel> get data => _logs;

  void add({required EntryModel log}) {
    _ids.remove(_Identifier(log.id));
    _ids.add(_Identifier(log.id));

    _logs.update(log.id, (old) => old.merge(log), ifAbsent: () => log);

    final evicted = _ids.length > _capacity ? _ids.firstOrNull : null;
    if (evicted != null) {
      _ids.remove(evicted);
      _logs.remove(evicted.value);
    }

    notifyListeners();
  }

  void clear() {
    _logs = {};
    _ids.clear();
    notifyListeners();
  }

  Set<Type> get types => {..._logs.values.map((e) => e.runtimeType)};
}

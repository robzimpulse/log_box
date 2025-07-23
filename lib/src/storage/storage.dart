import 'package:flutter/foundation.dart';

import '../model/entry_model.dart';

class Storage with ChangeNotifier {
  Map<String, EntryModel> _logs;

  final int _capacity;

  Storage({required int capacity}) : _logs = {}, _capacity = capacity;

  Map<String, EntryModel> get data => _logs;

  void add({required EntryModel log}) {
    var logs = {..._logs};

    logs.update(log.id, (old) => old.merge(log), ifAbsent: () => log);

    final data = [...logs.values]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _logs = {
      for (final (index, value) in data.indexed)
        if (index < _capacity) value.id: value,
    };

    notifyListeners();
  }

  void clear() {
    _logs = {};
    notifyListeners();
  }

  Set<Type> get types => {..._logs.values.map((e) => e.runtimeType)};
}

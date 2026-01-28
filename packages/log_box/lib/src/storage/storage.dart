import 'dart:async';

import 'package:log_box/src/extension/change_notifier_selector_stream.dart';
import 'package:rxdart/rxdart.dart';

import '../model/entry_model.dart';
import 'base/live_data_storage.dart';
import 'base/persistent_data_storage.dart';

class Storage {
  final LiveDataStorage _liveDataStorage;
  final PersistentDataStorage? _persistentDataStorage;
  final StreamSubscription _subscription;

  Storage({
    required LiveDataStorage liveDataStorage,
    PersistentDataStorage? persistentDataStorage,
  }) : _liveDataStorage = liveDataStorage,
       _persistentDataStorage = persistentDataStorage,
       _subscription = liveDataStorage.onDeleteEntry.listen(
         (e) => persistentDataStorage?.add(log: e),
       );

  LiveDataStorage get liveStorage => _liveDataStorage;

  PersistentDataStorage? get persistentStorage => _persistentDataStorage;

  /// Adding entry
  void add({required EntryModel log}) async {
    final persistence = persistentStorage;
    if (persistence == null) {
      _liveDataStorage.add(log: log);
      return;
    }

    final existing = await persistence.get(log.id);

    if (existing == null) {
      _liveDataStorage.add(log: log);
      return;
    }

    await persistence.add(log: log);
  }

  /// Clear all entry
  void clear() {
    _persistentDataStorage?.clear();
    _liveDataStorage.clear();
  }

  Stream<EntryModel> stream(String id) {
    final value = liveStorage.stream(
      () => liveStorage.data.where((e) => e.id == id).firstOrNull,
    );

    final persistentStorage = this.persistentStorage;
    if (persistentStorage == null) {
      return value.whereNotNull();
    }

    return CombineLatestStream.combine2(
      value,
      persistentStorage.getStream(id),
      (a, b) => a ?? b,
    );
  }

  /// dispose the storage
  Future<void> dispose() async {
    await _subscription.cancel();
    _liveDataStorage.dispose();
    await _persistentDataStorage?.dispose();
  }
}

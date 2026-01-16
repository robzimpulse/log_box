import 'dart:async';

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
  void add({required EntryModel log}) => _liveDataStorage.add(log: log);

  /// Clear all entry
  void clear() {
    _persistentDataStorage?.clear();
    _liveDataStorage.clear();
  }

  /// dispose the storage
  void dispose() {
    _subscription.cancel();
    _liveDataStorage.dispose();
  }
}

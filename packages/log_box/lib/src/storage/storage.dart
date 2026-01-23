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
  void add({required EntryModel log}) async {
    final persistence = persistentStorage;
    if (persistence == null) {
      _liveDataStorage.add(log: log);
      return;
    }

    final existing = await persistence
        .fetch(cursor: Cursor(id: log.id), limit: 1)
        .then((e) => e.firstOrNull);

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
    late StreamController<EntryModel> controller;

    // Define the listener function
    void listener() {
      final value = liveStorage.data.where((e) => e.id == id).firstOrNull;

      // feed forward data from [liveStorage] to controller if exists
      if (value != null) {
        controller.add(value);
        return;
      }

      liveStorage.removeListener(listener);

      // passing the value from [persistentStorage] if exists
      final storage = persistentStorage;
      if (storage != null) {
        controller
            .addStream(storage.stream(id))
            .then((_) => controller.close());
        return;
      }

      // close the controller if no [persistentStorage]
      controller.close();
    }

    controller = StreamController(
      onListen: () {
        // Immediately emit the current value when someone listens
        listener();
        liveStorage.addListener(listener);
      },
      onCancel: () {
        // Clean up the listener when the subscription ends
        liveStorage.removeListener(listener);
      },
    );

    return controller.stream;
  }

  /// dispose the storage
  Future<void> dispose() async {
    await _subscription.cancel();
    _liveDataStorage.dispose();
    await _persistentDataStorage?.dispose();
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:log_box/log_box.dart';

import 'dao/data_dao.dart';
import 'database/database.dart';
import 'database/executor/base.dart';
import 'util/typedef.dart';

class DriftPersistentStorage extends PersistentDataStorage {
  final DataDao _dao;
  final MapObjectDecoder? _decoder;

  DriftPersistentStorage({
    required Executor executor,
    MapObjectDecoder? decoder,
  }) : _dao = DataDao(AppDatabase(executor: executor)),
       _decoder = decoder;

  @override
  Future<void> add({required EntryModel log}) =>
      _dao.add(log: log).catchError((e, st) => print(e));

  @override
  Future<void> clear() => _dao.clear();

  @override
  Future<List<EntryModel>> fetch({
    required Cursor cursor,
    int limit = 20,
  }) async {
    final result = await _dao.fetch(
      refId: cursor.id,
      types: cursor.types.toSet(),
      fetchBefore: cursor.direction == PageDirection.before,
      limit: limit,
    );

    return result.map(_transform).nonNulls.toList();
  }

  @override
  Stream<EntryModel> stream(String id) {
    return _dao.single(id).transform(_transformer);
  }

  @override
  Stream<Set<String>> get types => _dao.types.map((e) => e.toSet());

  StreamTransformer<DataDrift, EntryModel> get _transformer {
    return StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        final log = _transform(data);
        if (log == null) return;
        sink.add(log);
      },
    );
  }

  EntryModel? _transform(DataDrift data) {
    final decoder = _decoder?[data.type];
    final json = data.json;
    if (json == null || decoder == null) return null;
    return decoder.call(jsonDecode(json));
  }
}

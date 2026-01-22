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
  }) : _dao = DataDao(LogBoxPersistentDatabase(executor: executor)),
       _decoder = decoder;

  @override
  Future<void> add({required EntryModel log}) => _dao.add(log: log);

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
      keyword: cursor.keyword,
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
  Stream<Map<String, Type>> get types {
    return _dao.latestDistinctByType.map((result) {
      final data = <String, Type>{};

      for (final element in result) {
        final log = _transform(element);
        if (log == null) continue;
        data[log.display()] = log.runtimeType;
      }

      return data;
    });
  }

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

  @override
  Future<void> dispose() async {
    await _dao.close();
  }
}

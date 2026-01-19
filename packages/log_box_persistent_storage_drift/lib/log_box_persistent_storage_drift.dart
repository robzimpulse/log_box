import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:log_box/log_box.dart';

import 'src/dao/data_dao.dart';
import 'src/database/database.dart';
import 'src/database/executor/base.dart';
import 'src/util/typedef.dart';

class DriftPersistentStorage extends PersistentDataStorage {
  final DataDao _dao;
  final MapObjectDecoder? _decoder;

  DriftPersistentStorage({
    required Executor executor,
    MapObjectDecoder? decoder,
  }) : _dao = DataDao(AppDatabase(executor: executor)),
       _decoder = decoder;

  @override
  Future<void> add({required EntryModel log}) => _dao.add(log: log);

  @override
  Future<void> clear() => _dao.clear();

  @override
  Future<List<EntryModel>> fetch({required Cursor cursor, int limit = 20}) {
    return _dao
        .fetch(
          refId: cursor.id,
          types: cursor.types.toSet(),
          fetchBefore: cursor.direction == PageDirection.before,
          limit: limit,
        )
        .then((e) => e.map(_transform).nonNulls.toList());
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

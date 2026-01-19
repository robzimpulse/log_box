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
    // TODO: implement fetch
    throw UnimplementedError();
  }

  @override
  Stream<EntryModel> stream(String id) {
    final transformer = StreamTransformer<DataDrift, EntryModel>.fromHandlers(
      handleData: (data, sink) {
        final decoder = _decoder?[data.type];
        final json = data.json;
        if (json == null || decoder == null) return;
        sink.add(decoder.call(jsonDecode(json)));
      }
    );

    return _dao.single(id).transform(transformer);
  }

  @override
  Stream<Set<String>> get types => _dao.types.map((e) => e.toSet());
}

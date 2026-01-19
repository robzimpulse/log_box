import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:log_box/log_box.dart';

import '../database/database.dart';
import '../table/data_tables.dart';

part 'data_dao.g.dart';

@DriftAccessor(tables: [DataTables])
class DataDao extends DatabaseAccessor<AppDatabase> with _$DataDaoMixin {
  DataDao(super.db);

  Future<void> add({required EntryModel log}) {
    return transaction(() async {
      final json = log.toJson();
      final jsonString = jsonEncode(json);
      final bytes = utf8.encode(jsonString);

      final companion = DataTablesCompanion.insert(
        uid: Value(log.id),
        type: Value(log.runtimeType.toString()),
        data: Value(bytes),
      );

      await into(dataTables).insert(companion);
    });
  }

  Future<void> clear() => transaction(() => delete(dataTables).go());

  // @override
  // Future<List<DataDrift>> fetch({required Cursor cursor, int limit = 20}) {
  //   // TODO: implement fetch
  //   throw UnimplementedError();
  // }

  Stream<DataDrift> single(String uid) {
    final selector = select(dataTables)
      ..where((t) => t.uid.equals(uid))
      ..limit(1);

    return selector.watchSingle();
  }

  Stream<List<String>> get types {
    final selector = selectOnly(dataTables, distinct: true)
      ..addColumns([dataTables.type]);

    return selector.watch().map(
      (e) => e.map((e) => e.read(dataTables.type)).nonNulls.toList(),
    );
  }
}

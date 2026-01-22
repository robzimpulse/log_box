// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_dao.dart';

// ignore_for_file: type=lint
mixin _$DataDaoMixin on DatabaseAccessor<LogBoxPersistentDatabase> {
  $DataTablesTable get dataTables => attachedDatabase.dataTables;
  Selectable<LatestDistinctRowByTypeResult> latestDistinctRowByType() {
    return customSelect(
      'SELECT * FROM (SELECT *, ROW_NUMBER()OVER (PARTITION BY type ORDER BY created_at DESC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS rn FROM data_tables) WHERE rn = 1',
      variables: [],
      readsFrom: {dataTables},
    ).map(
      (QueryRow row) => LatestDistinctRowByTypeResult(
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
        id: row.read<int>('id'),
        uid: row.readNullable<String>('uid'),
        type: row.readNullable<String>('type'),
        json: row.readNullable<String>('json'),
        rn: row.read<int>('rn'),
      ),
    );
  }

  DataDaoManager get managers => DataDaoManager(this);
}

class DataDaoManager {
  final _$DataDaoMixin _db;
  DataDaoManager(this._db);
  $$DataTablesTableTableManager get dataTables =>
      $$DataTablesTableTableManager(_db.attachedDatabase, _db.dataTables);
}

class LatestDistinctRowByTypeResult {
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String? uid;
  final String? type;
  final String? json;
  final int rn;
  LatestDistinctRowByTypeResult({
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.uid,
    this.type,
    this.json,
    required this.rn,
  });
}

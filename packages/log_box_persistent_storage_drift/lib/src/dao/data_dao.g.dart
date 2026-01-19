// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_dao.dart';

// ignore_for_file: type=lint
mixin _$DataDaoMixin on DatabaseAccessor<AppDatabase> {
  $DataTablesTable get dataTables => attachedDatabase.dataTables;
  DataDaoManager get managers => DataDaoManager(this);
}

class DataDaoManager {
  final _$DataDaoMixin _db;
  DataDaoManager(this._db);
  $$DataTablesTableTableManager get dataTables =>
      $$DataTablesTableTableManager(_db.attachedDatabase, _db.dataTables);
}

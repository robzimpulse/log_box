import 'package:drift/drift.dart';

mixin AutoIntegerIdTable on Table {
  IntColumn get id => integer().named('id').autoIncrement()();
}
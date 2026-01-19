import 'package:drift/drift.dart';
import 'package:file/file.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'base.dart';

import '../../adapter/filesystem_adapter/filesystem_adapter.dart'
    if (dart.library.js_interop) '../../adapter/filesystem_adapter/filesystem_adapter_web.dart'
    if (dart.library.io) '../../adapter/filesystem_adapter/filesystem_adapter_io.dart'
    as fs;

class FileExecutor extends Executor {
  final String name;
  final String path;

  FileExecutor({this.name = 'log_box_persistence_drift', required this.path});

  @override
  QueryExecutor get executor {
    return LazyDatabase(
      () => driftDatabase(
        name: name,
        native: DriftNativeOptions(databaseDirectory: () => directory),
      ),
    );
  }

  Future<File> get file {
    return directory.then(
      (e) => e.childFile('$name.sqlite').create(recursive: true),
    );
  }

  Future<Directory> get directory {
    return fs.filesystem().directory(path).create(recursive: true);
  }
}

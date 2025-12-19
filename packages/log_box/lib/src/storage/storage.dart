import 'dart:convert';

import 'package:file/file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/entry_model.dart';

typedef ToEntry = EntryModel Function(Map<String, dynamic> json);

typedef StorageCodec = Map<String, ToEntry>;

class Storage with ChangeNotifier {
  /// Handle mapping between data and id
  Map<String, EntryModel> _logs;

  final Directory _root;

  FileSystem _fileSystem;

  /// Codec for decoding data [EntryModel] from storage
  final StorageCodec _codec;

  Storage({StorageCodec codec = const {}, required Directory root})
    : _logs = const {},
      _codec = codec,
      _root = root,
      _fileSystem = root.fileSystem;

  Map<String, EntryModel> get data => _logs;

  Future<void> add({required EntryModel log}) async {
    final type = log.runtimeType.toString();
    final decoder = _codec[type];

    if (decoder == null) {
      throw Exception('No decoder for type $type');
    }

    final filename = '$type-${log.id}.json';
    final file = _root.childFile(filename);

    try {
      if (!await file.exists()) throw Exception('File not found');
      final Map<String, dynamic> json = jsonDecode(await file.readAsString());
      final old = decoder(json);
      final updated = old.merge(log);
      await file.writeAsString(jsonEncode(updated));
    } catch (e) {
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(log.toJson()));
    } finally {
      _fileSystem = file.fileSystem;
    }

    await _refresh();
  }

  Future<void> clear() async {
    _logs = {};
    if (await _root.exists()) {
      await _root.delete(recursive: true);
    }
    await _refresh();
  }

  Map<String, Type> get types {
    return _logs.map((k, v) => MapEntry(v.display(), v.runtimeType));
  }

  Future<void> _refresh() async {
    if (!await _root.exists()) {
      Future.microtask(() => notifyListeners());
      return;
    }
    final files = await _root.list().toList();
    for (final entity in files) {
      final components = [
        for (final segments in entity.basename.split('.'))
          for (final segment in segments.split('-')) segment,
      ];
      final type = components.first;
      final decoder = _codec[type];
      if (decoder == null) continue;

      final file = _root.childFile(entity.basename);
      final Map<String, dynamic> json = jsonDecode(await file.readAsString());
      final object = decoder(json);
      _logs = {..._logs, object.id: object};
    }
    Future.microtask(() => notifyListeners());
  }
}

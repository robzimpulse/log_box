import 'dart:convert';

import 'package:file/file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:queue/queue.dart';

import '../model/entry_model.dart';

typedef ToEntry = EntryModel Function(Map<String, dynamic> json);

typedef StorageCodec = Map<String, ToEntry>;

class Storage with ChangeNotifier {
  /// Handle mapping between data and id
  final Map<String, EntryModel> _logs = {};

  final Directory _root;

  FileSystem _fileSystem;

  final Map<String, Queue> _queues = {};

  /// Codec for decoding data [EntryModel] from storage
  final StorageCodec _codec;

  Storage({StorageCodec codec = const {}, required Directory root})
    : _codec = codec,
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

    final queue = _queues.update(
      filename,
      (old) {
        old.add(() => _add(log: log, file: file, decoder: decoder));
        return old;
      },
      ifAbsent: () {
        final queue = Queue();
        queue.add(() => _add(log: log, file: file, decoder: decoder));
        queue.onComplete.whenComplete(() => _queues.remove(filename));
        return queue;
      },
    );

    return queue.onComplete;
  }

  Future<void> _add({
    required EntryModel log,
    required File file,
    required ToEntry decoder,
  }) async {
    try {
      if (!await file.exists()) throw Exception('File not found');
      final data = await file.readAsString();
      if (data.isEmpty) throw Exception('File is empty');
      final Map<String, dynamic> json = jsonDecode(data);
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
    _logs.clear();
    _fileSystem = _root.fileSystem;
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

      try {
        final file = _root.childFile(entity.basename);
        final data = await file.readAsString();
        final Map<String, dynamic> json = jsonDecode(data);
        final object = decoder(json);
        _logs[object.id] = object;
      } catch (e) {
        continue;
      }
    }
    Future.microtask(() => notifyListeners());
  }
}

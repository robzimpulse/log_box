import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';

typedef ObjectDecoder = EntryModel? Function(Map<String, dynamic> json);
typedef MapObjectDecoder = Map<String, ObjectDecoder>;

class FileStorage with ChangeNotifier implements Storage {
  final MapObjectDecoder? _coder;
  final Duration _throttle;
  final Directory _root;
  Timer? _timer;

  static Future<FileStorage> create({
    required Directory root,
    Duration throttle = const Duration(seconds: 1),
    MapObjectDecoder? coder,
  }) async {
    return FileStorage._(
      root: await root.create(recursive: true),
      throttle: throttle,
      coder: coder,
    );
  }

  FileStorage._({
    required Directory root,
    Duration throttle = const Duration(seconds: 1),
    MapObjectDecoder? coder,
  }) : _throttle = throttle,
       _coder = coder,
       _root = root;

  // void _init() async {
  //   final files = await _root.list().toList();
  //   for (final file in files.whereType<File>()) {
  //     try {
  //       final type = file.path.split('/').lastOrNull?.split('-').firstOrNull;
  //       final coder = _coder?[type];
  //       if (coder == null || type == null) continue;
  //       final data = await file.readAsString();
  //       final log = coder.call(jsonDecode(data));
  //       if (log == null) continue;
  //       _logs[log.id] = log;
  //     } catch (e) {
  //       dev.log(e.toString(), name: 'Log Box File Storage');
  //     }
  //   }
  //   notifyListeners();
  // }

  @override
  void add({required EntryModel log}) async {
    final file = _root.childFile('${log.runtimeType}-${log.id}.json');
    try {
      await file.writeAsString(jsonEncode(log.toJson()));
    } catch (e) {
      dev.log(e.toString(), name: 'Log Box File Storage');
    } finally {
      notifyListeners();
    }
  }

  @override
  void clear() async {
    try {
      for (final file in await _root.list().toList()) {
        await file.delete();
      }
    } catch (e) {
      dev.log(e.toString(), name: 'Log Box File Storage');
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Map<String, EntryModel>> get data async {
    final files = await _root.list().toList();
    final result = <String, EntryModel>{};
    for (final file in files.whereType<File>()) {
      try {
        final type = file.path.split('/').lastOrNull?.split('-').firstOrNull;
        final coder = _coder?[type];
        if (coder == null || type == null) continue;
        final data = await file.readAsString();
        final log = coder.call(jsonDecode(data));
        if (log == null) continue;
        result[log.id] = log;
      } catch (e) {
        dev.log(e.toString(), name: 'Log Box File Storage');
      }
    }
    return result;
  }

  @override
  Future<Map<String, Type>> get types async {
    return (await data).map((k, v) => MapEntry(v.display(), v.runtimeType));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void notifyListeners() {
    _timer?.cancel();
    _timer = Timer(_throttle, super.notifyListeners);
  }
}

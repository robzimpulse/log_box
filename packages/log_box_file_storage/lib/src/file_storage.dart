import 'dart:convert';
import 'dart:developer' as dev;

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';

typedef ObjectCoder = EntryModel? Function(Map<String, dynamic> json);

class FileStorage with ChangeNotifier implements Storage {
  final ObjectCoder? _coder;
  final Duration _throttle;
  final Directory _root;
  final Map<String, Type> _types = const {};
  DateTime _lastNotify = DateTime.timestamp();

  FileStorage({
    required Directory root,
    Duration throttle = const Duration(seconds: 1),
    ObjectCoder? coder,
  }) : _throttle = throttle,
       _coder = coder,
       _root = root {
    _init();
  }

  void _init() async {
    final files = await _root.list().toList();
    for (final file in files.whereType<File>()) {
      final data = await file.readAsString();
      final model = _coder?.call(jsonDecode(data));
      if (model == null) continue;
      _types[model.display()] = model.runtimeType;
    }
    notifyListeners();
  }

  @override
  void add({required EntryModel log}) async {
    final file = _root.childFile('${log.id}.json');
    try {
      await file.writeAsString(jsonEncode(log.toJson()));
      _types[log.display()] = log.runtimeType;
    } catch (e) {
      dev.log(e.toString(), name: 'Log Box File Storage');
    } finally {
      notifyListeners();
    }
  }

  @override
  void clear() async {
    for (final file in await _root.list().toList()) {
      await file.delete();
    }
    _types.clear();
    notifyListeners();
  }

  @override
  // TODO: rework how we fetch data
  Map<String, EntryModel> get data => throw UnimplementedError();

  @override
  Map<String, Type> get types => {..._types};

  @override
  void notifyListeners() {
    final now = DateTime.timestamp();
    if (now.difference(_lastNotify) < _throttle) return;
    _lastNotify = now;
    Future.microtask(() => super.notifyListeners());
  }
}

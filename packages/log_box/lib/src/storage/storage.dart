import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/entry_model.dart';

abstract class Storage with ChangeNotifier {
  /// Event when data being deleted caused by over capacity or clearing data
  Stream<EntryModel> get onDeleteEntry;

  /// Get all data stored
  Map<String, EntryModel> get data;

  /// get all data types
  Map<String, Type> get types;

  /// Adding entry
  void add({required EntryModel log});

  /// Clear all entry
  void clear();
}

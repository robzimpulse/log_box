import 'package:flutter/foundation.dart';

import '../model/entry_model.dart';

abstract class Storage with ChangeNotifier {
  /// Get all data stored
  Future<Map<String, EntryModel>> get data;

  /// get all data types
  Future<Map<String, Type>> get types;

  /// Adding entry
  void add({required EntryModel log});

  /// Clear all entry
  void clear();
}

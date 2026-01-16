import 'package:flutter/foundation.dart';

import '../../model/entry_model.dart';

abstract class LiveDataStorage with ChangeNotifier {
  /// Get all data stored
  List<EntryModel> get data;

  /// get all data types
  Map<String, Type> get types;

  /// Adding entry
  void add({required EntryModel log});

  /// Clear all entry
  void clear();

  Stream<EntryModel> get onDeleteEntry;
}
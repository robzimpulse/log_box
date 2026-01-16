import '../../model/entry_model.dart';

typedef ObjectDecoder = EntryModel? Function(Map<String, dynamic> json);
typedef MapObjectDecoder = Map<String, ObjectDecoder>;

enum FetchDirection {
  previous, after;
}

abstract class PersistentDataStorage {
  /// Adding entry
  Future<void> add({required EntryModel log});

  /// fetch entry after [after] key with limit [limit] and types [types]
  Future<List<EntryModel>> fetch({
    String? reference,
    int limit = 30,
    List<Type> types = const [],
    FetchDirection direction = FetchDirection.after,
  });

  /// Listen to entry with [id]
  Stream<EntryModel> stream(String id);

  /// get all data types
  Future<Map<String, Type>> get types;

  /// Clear all entry
  Future<void> clear();
}

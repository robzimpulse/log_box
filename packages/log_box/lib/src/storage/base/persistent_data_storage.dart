import 'package:super_paging/super_paging.dart';

import '../../model/entry_model.dart';

enum PageDirection { before, after }

class Cursor {
  final String? id;
  final String? keyword;
  final List<String> types;
  final PageDirection direction;

  const Cursor({
    this.id,
    this.keyword,
    this.types = const [],
    this.direction = PageDirection.after,
  });

  Cursor copyWith({
    String? id,
    String? keyword,
    List<String>? types,
    PageDirection? direction,
  }) {
    return Cursor(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      types: types ?? this.types,
      direction: direction ?? this.direction,
    );
  }
}

abstract class PersistentDataStorage extends PagingSource<Cursor, EntryModel> {
  /// Adding entry
  Future<void> add({required EntryModel log});

  /// fetch entry with [param] and limit [limit], this will return previous or
  /// next data based on [cursor.direction] with limit [limit].
  Future<List<EntryModel>> fetch({required Cursor cursor, int limit = 20});

  /// watch entry with [param] and limit [limit], this will return previous or
  /// next data based on [cursor.direction] with limit [limit].
  Stream<List<EntryModel>> fetchStream({
    required Cursor cursor,
    int limit = 20,
  });

  /// Listen to entry with [id]
  Stream<EntryModel> getStream(String id);

  /// get to entry with [id]
  Future<EntryModel?> get(String id);

  /// get all data types of entry
  Stream<Map<String, Type>> get types;

  /// Clear all entry
  Future<void> clear();

  /// dispose this storage
  Future<void> dispose();

  @override
  Future<LoadResult<Cursor, EntryModel>> load(LoadParams<Cursor> params) async {
    try {
      final curr = params.key ?? Cursor();
      List<EntryModel> result;
      String? nextId;
      Cursor? next;
      String? prevId;
      Cursor? prev;

      result = await fetch(cursor: curr, limit: params.loadSize);
      nextId = result.lastOrNull?.id;
      prevId = result.firstOrNull?.id;

      if (result.isEmpty && curr.direction == PageDirection.before) {
        final stream = fetchStream(cursor: curr, limit: params.loadSize);
        result = await stream.firstWhere((e) => e.isNotEmpty);
        nextId = result.lastOrNull?.id;
        prevId = result.firstOrNull?.id;
      }

      if (nextId != null) {
        next = curr.copyWith(id: nextId, direction: PageDirection.after);
      }

      if (prevId != null) {
        prev = curr.copyWith(id: prevId, direction: PageDirection.before);
      }

      return LoadResult.page(items: result, nextKey: next, prevKey: prev);
    } catch (e) {
      return LoadResult.error(e);
    }
  }
}

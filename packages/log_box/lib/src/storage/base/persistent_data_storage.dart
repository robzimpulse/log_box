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

  /// fetch entry with [param] and limit [limit]
  Future<List<EntryModel>> fetch({required Cursor cursor, int limit = 20});

  /// Listen to entry with [id]
  Stream<EntryModel> stream(String id);

  /// get all data types of entry
  Stream<Map<String, Type>> get types;

  /// Clear all entry
  Future<void> clear();

  @override
  Future<LoadResult<Cursor, EntryModel>> load(LoadParams<Cursor> params) async {
    try {
      final cursor = params.key ?? Cursor();
      final result = await fetch(cursor: cursor, limit: params.loadSize);
      return LoadResult.page(
        items: result,
        nextKey: cursor.copyWith(
          id: result.lastOrNull?.id,
          direction: PageDirection.after,
        ),
        prevKey: cursor.copyWith(
          id: result.firstOrNull?.id,
          direction: PageDirection.before,
        ),
      );
    } catch (e) {
      return LoadResult.error(e);
    }
  }
}

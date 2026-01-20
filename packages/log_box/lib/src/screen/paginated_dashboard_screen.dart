import 'package:flutter/material.dart';
import 'package:super_paging/super_paging.dart';

import '../log_box.dart';
import '../model/entry_model.dart';
import '../storage/base/persistent_data_storage.dart';

class PaginatedDashboardScreen extends StatefulWidget {
  const PaginatedDashboardScreen({
    super.key,
    required this.box,
    this.onTapEntry,
  });

  final LogBox box;

  final void Function(EntryModel value, String keyword)? onTapEntry;

  @override
  State<PaginatedDashboardScreen> createState() =>
      _PaginatedDashboardScreenState();
}

class _PaginatedDashboardScreenState extends State<PaginatedDashboardScreen> {
  final searchController = TextEditingController();
  final focusNode = FocusNode();

  final keyword = ValueNotifier<String>('');
  final isSearchMode = ValueNotifier<bool>(false);
  final selectedTypes = ValueNotifier<Set<String>>({});

  Pager<Cursor, EntryModel>? pager;

  @override
  void initState() {
    super.initState();

    final source = widget.box.storage.persistentStorage;
    if (source != null) {
      pager = Pager(
        initialKey: Cursor(),
        config: const PagingConfig(pageSize: 10, initialLoadSize: 30),
        pagingSourceFactory: () => source,
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    keyword.dispose();
    isSearchMode.dispose();
    selectedTypes.dispose();
    pager?.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    final isSearch = isSearchMode.value;

    if (isSearch) {
      keyword.value = '';
      focusNode.unfocus();
    } else {
      keyword.value = searchController.text;
      focusNode.requestFocus();
    }

    isSearchMode.value = !isSearch;
  }

  Widget _item({required BuildContext context, required EntryModel value}) {
    final hasDetail = value.tabLength(context) > 0;

    return ListTile(
      onTap: hasDetail
          ? () => widget.onTapEntry?.call(value, keyword.value)
          : null,
      visualDensity: VisualDensity.compact,
      title: value.title(context),
      subtitle: value.subtitle(context),
      trailing: hasDetail ? const Icon(Icons.chevron_right) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !isSearchMode.value,
      onPopInvokedWithResult: (success, _) => !success ? _toggleSearch() : {},
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ValueListenableBuilder(
              valueListenable: isSearchMode,
              builder: (context, isSearch, _) {
                return IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(isSearch ? Icons.close : Icons.search),
                );
              },
            ),
            IconButton(
              onPressed: () => widget.box.storage.persistentStorage?.clear(),
              icon: const Icon(Icons.delete),
            ),
          ],
          title: ValueListenableBuilder(
            valueListenable: isSearchMode,
            builder: (context, isSearch, _) {
              if (!isSearch) return const Text('Log Dashboard');
              return Container(
                alignment: Alignment.centerLeft,
                child: TextField(
                  autofocus: true,
                  onChanged: (text) => keyword.value = text,
                  onSubmitted: (text) {
                    pager?.refresh(
                      refreshKey: Cursor(
                        keyword: text,
                        types: [
                          ...selectedTypes.value.map((e) => e.toString()),
                        ],
                      ),
                    );
                  },
                  focusNode: focusNode,
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: false,
                    border: InputBorder.none,
                    hintStyle: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  cursorColor: Colors.white,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _types(),
              Expanded(child: _content()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _types() {
    final stream = widget.box.storage.persistentStorage?.types;
    if (stream == null) return SizedBox.shrink();

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final error = snapshot.error;

        if (snapshot.connectionState != ConnectionState.active) {
          return SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (error != null) {
          return SizedBox(
            height: 50,
            child: Center(child: Text(error.toString())),
          );
        }

        if (data == null || data.isEmpty) {
          return SizedBox(height: 50, child: Center(child: Text('No Data')));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              direction: Axis.horizontal,
              children: [
                for (final key in data)
                  Builder(
                    builder: (context) {
                      final selected = selectedTypes.value.contains(key);
                      return OutlinedButton(
                        onPressed: () {
                          var data = {...selectedTypes.value};
                          selected ? data.remove(key) : data.add(key);
                          selectedTypes.value = data;
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected ? Colors.grey : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(key),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content() {
    final pager = this.pager;
    if (pager == null) return Center(child: Text('No Data'));

    return PagingListView(
      pager: pager,
      itemBuilder: (context, index) {
        final item = pager.items.elementAt(index);
        return _item(context: context, value: item);
      },
      emptyBuilder: (context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No Data Found'),
              TextButton(
                onPressed: () => pager.refresh(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      },
      errorBuilder: (context, error) {
        return Center(child: Text('$error'));
      },
      loadingBuilder: (context) {
        return const Center(child: CircularProgressIndicator.adaptive());
      },
    );
  }
}

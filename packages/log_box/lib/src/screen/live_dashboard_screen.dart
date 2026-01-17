import 'package:flutter/material.dart';

import '../log_box.dart';
import '../model/entry_model.dart';

class LiveDashboardScreen extends StatefulWidget {
  const LiveDashboardScreen({
    super.key,
    required this.box,
    this.onTapEntry,
    this.onTapPaginated,
  });

  final LogBox box;

  final void Function(EntryModel value, String keyword)? onTapEntry;

  final VoidCallback? onTapPaginated;

  @override
  State<LiveDashboardScreen> createState() => _LiveDashboardScreenState();
}

class _LiveDashboardScreenState extends State<LiveDashboardScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final ValueNotifier<String> keyword = ValueNotifier('');
  final ValueNotifier<bool> isSearchMode = ValueNotifier(false);
  final ValueNotifier<Set<Type>> selectedTypes = ValueNotifier({});

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    keyword.dispose();
    isSearchMode.dispose();
    selectedTypes.dispose();
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

  bool _filter({
    required EntryModel value,
    required String keyword,
    Set<Type> types = const {},
  }) {
    return [
      value.contains(keyword),
      if (types.isNotEmpty) types.contains(value.runtimeType),
    ].every((e) => e);
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
              onPressed: widget.onTapPaginated,
              icon: const Icon(Icons.storage),
            ),
            IconButton(
              onPressed: () => widget.box.storage.clear(),
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
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.box.storage.liveStorage,
        selectedTypes,
      ]),
      builder: (context, _) {
        final mappedTypes = {...widget.box.storage.liveStorage.types};
        final keys = [...mappedTypes.keys]..sort((a, b) => a.compareTo(b));

        if (keys.isEmpty) return const SizedBox.shrink();

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
                for (final key in keys)
                  Builder(
                    builder: (context) {
                      final type = mappedTypes[key];
                      if (type == null) return SizedBox.shrink();
                      final selected = selectedTypes.value.contains(type);
                      return OutlinedButton(
                        onPressed: () {
                          var data = {...selectedTypes.value};
                          selected ? data.remove(type) : data.add(type);
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
    return AnimatedBuilder(
      animation: Listenable.merge([
        keyword,
        widget.box.storage.liveStorage,
        selectedTypes,
      ]),
      builder: (context, _) {
        final data = widget.box.storage.liveStorage.data;

        final filtered = data.reversed.where(
          (e) => _filter(
            value: e,
            keyword: keyword.value,
            types: selectedTypes.value,
          ),
        );

        if (filtered.isEmpty) {
          return Center(child: Text('No Data'));
        }

        return ListView.separated(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final entry = filtered.elementAtOrNull(index);
            if (entry == null) return null;
            return _item(context: context, value: entry);
          },
          separatorBuilder: (context, index) {
            return const Divider(height: 1);
          },
        );
      },
    );
  }
}

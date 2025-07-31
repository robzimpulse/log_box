import 'package:flutter/material.dart';

import '../model/entry_model.dart';
import '../storage/storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.storage, this.onTap});

  final Storage storage;

  final ValueSetter<EntryModel>? onTap;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    isSearchMode.value = !isSearch;
    if (!isSearch) {
      keyword.value = '';
      searchController.clear();
      focusNode.unfocus();
    }
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
    final hasDetail = value.tabs(context).isNotEmpty;

    return ListTile(
      onTap: hasDetail ? () => widget.onTap?.call(value) : null,
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
              onPressed: () => widget.storage.clear(),
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
            children: [_types(), Expanded(child: _content())],
          ),
        ),
      ),
    );
  }

  Widget _types() {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.storage, selectedTypes]),
      builder: (context, _) {
        if (widget.storage.types.isEmpty) return const SizedBox.shrink();

        final mappedTypes = {...widget.storage.types};
        final keys = [...mappedTypes.keys]..sort((a, b) => a.compareTo(b));

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
      animation: Listenable.merge([keyword, widget.storage, selectedTypes]),
      builder: (context, _) {
        final data = widget.storage.data.values.where(
          (e) => _filter(
            value: e,
            keyword: keyword.value,
            types: selectedTypes.value,
          ),
        );

        final reversed = [...data].reversed;

        if (reversed.isEmpty) {
          return Center(child: Text('No Data'));
        }

        return ListView.separated(
          itemCount: reversed.length,
          itemBuilder: (context, index) {
            final entry = reversed.elementAtOrNull(index);
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

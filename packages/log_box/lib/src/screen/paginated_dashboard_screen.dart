import 'package:flutter/material.dart';

import '../log_box.dart';
import '../model/entry_model.dart';

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
              Expanded(child: Container()),
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

        final keys = [...data.keys]..sort((a, b) => a.compareTo(b));

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
                      final type = data[key];
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
}

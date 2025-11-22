import 'package:flutter/material.dart';

import '../log_box.dart';
import '../model/entry_model.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.data,
    required this.box,
    this.keyword = '',
  });

  final EntryModel data;
  final LogBox box;
  final String keyword;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  final ValueNotifier<String> keyword = ValueNotifier('');
  final ValueNotifier<bool> isSearchMode = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    searchController.text = widget.keyword;
    keyword.value = widget.keyword;
    isSearchMode.value = widget.keyword.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant DetailScreen oldWidget) {
    if (widget.keyword != oldWidget.keyword) {
      searchController.text = widget.keyword;
      keyword.value = widget.keyword;
      isSearchMode.value = widget.keyword.isNotEmpty;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    keyword.dispose();
    isSearchMode.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([isSearchMode, keyword]),
      builder: (context, _) {
        final theme = Theme.of(context);

        final tabs = widget.data.tabs(
          context,
          searchTerm: keyword.value.isEmpty ? null : keyword.value,
        );

        return DefaultTabController(
          length: widget.data.tabLength(context),
          child: Scaffold(
            appBar: AppBar(
              title:
                  !isSearchMode.value
                      ? const Text('Detail Log')
                      : Container(
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
                      ),
              elevation: 3,
              centerTitle: false,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              actions: [
                IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(isSearchMode.value ? Icons.close : Icons.search),
                ),
                ...widget.data.menus(context, widget.box),
              ],
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: tabs.keys.toList(),
              ),
            ),
            body: SafeArea(child: TabBarView(children: tabs.values.toList())),
          ),
        );
      },
    );
  }
}

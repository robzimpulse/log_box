import 'package:flutter/material.dart';

import '../log_box.dart';
import '../model/entry_model.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.id,
    required this.box,
    this.keyword = '',
  });

  final String id;
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

    if (isSearch) {
      keyword.value = '';
      focusNode.unfocus();
    } else {
      keyword.value = searchController.text;
      focusNode.requestFocus();
    }

    isSearchMode.value = !isSearch;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.box.storage.stream(widget.id).distinct(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final error = snapshot.error;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (error != null) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text(error.toString())),
          );
        }

        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: Text('No Data')),
            body: Center(child: Text('No Data')),
          );
        }

        return _content(context, data);
      },
    );
  }

  Widget _content(BuildContext context, EntryModel data) {
    return ValueListenableBuilder(
      valueListenable: keyword,
      builder: (context, value, _) {
        final theme = Theme.of(context);

        final tabs = data.tabs(
          context,
          searchTerm: value.isEmpty ? null : value,
        );

        return DefaultTabController(
          length: data.tabLength(context),
          child: Scaffold(
            appBar: _appBar(context, theme, data, tabs),
            body: SafeArea(child: TabBarView(children: tabs.values.toList())),
          ),
        );
      },
    );
  }

  AppBar _appBar(
    BuildContext context,
    ThemeData theme,
    EntryModel data,
    Map<Tab, Widget> tabs,
  ) {
    return AppBar(
      title: ValueListenableBuilder(
        valueListenable: isSearchMode,
        builder: (context, value, _) {
          if (!value) return const Text('Detail Log');
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
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
          );
        },
      ),
      elevation: 3,
      centerTitle: false,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        ValueListenableBuilder(
          valueListenable: isSearchMode,
          builder: (context, value, _) {
            return IconButton(
              onPressed: _toggleSearch,
              icon: Icon(isSearchMode.value ? Icons.close : Icons.search),
            );
          },
        ),
        ...data.menus(context, widget.box),
      ],
      bottom: TabBar(
        labelColor: theme.appBarTheme.foregroundColor,
        unselectedLabelColor: theme.appBarTheme.foregroundColor,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: tabs.keys.toList(),
      ),
    );
  }
}

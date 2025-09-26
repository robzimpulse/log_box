import 'package:flutter/material.dart';

import '../log_box.dart';
import '../model/entry_model.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.data, required this.box});

  final EntryModel data;
  final LogBox box;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String searchTerm = '';
  bool isSearchActive = false;

  Widget _buildTitle(BuildContext context) {
    final appBarForegroundColor = Theme.of(context).appBarTheme.foregroundColor;
    final hintStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(color: appBarForegroundColor);

    if (isSearchActive) {
      return TextField(
        cursorColor: appBarForegroundColor,
        style: hintStyle,
        onSubmitted: (text) {
          setState(() {
            searchTerm = text;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search...',
          filled: false,
          border: InputBorder.none,
          hintStyle: hintStyle,
        ),
      );
    }

    return const Text('Detail Log');
  }

  Widget _buildSearchMenu(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          isSearchActive = !isSearchActive;
        });
      },
      icon: Icon(isSearchActive ? Icons.close : Icons.search),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.data.tabs(
      context,
      searchTerm: searchTerm.isEmpty ? null : searchTerm,
    );

    return DefaultTabController(
      length: widget.data.tabLength(context),
      child: Scaffold(
        appBar: AppBar(
          title: _buildTitle(context),
          elevation: 3,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            _buildSearchMenu(context),
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
  }
}

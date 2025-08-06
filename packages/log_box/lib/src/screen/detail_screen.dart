import 'package:flutter/material.dart';

import '../log_box.dart';
import '../model/entry_model.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.data, required this.box});

  final EntryModel data;
  final LogBox box;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: data.tabLength(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Log'),
          elevation: 3,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: data.menus(context, box),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [...data.tabs(context).keys],
          ),
        ),
        body: SafeArea(
          child: TabBarView(children: [...data.tabs(context).values]),
        ),
      ),
    );
  }

}
import 'package:flutter/material.dart';

import '../model/entry_model.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.data});

  final EntryModel data;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: data.tabs(context).length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Detail Log'),
          elevation: 3,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            // TODO: add action based on data
          ],
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
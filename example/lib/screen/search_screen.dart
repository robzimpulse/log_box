import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Center(
        child: TextButton(
          onPressed: () => context.push('/screen_1'),
          child: Text('Push to Screen 1'),
        ),
      ),
    );
  }
}

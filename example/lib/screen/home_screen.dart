import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: TextButton(
          onPressed: () => context.push('/screen_1'),
          child: Text('Push to Screen 1'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: Center(
        child: TextButton(
          onPressed: () => context.push('/screen_1'),
          child: Text('Push to Screen 1'),
        ),
      ),
    );
  }
}

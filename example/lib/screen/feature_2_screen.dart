import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Feature2Screen extends StatelessWidget {
  const Feature2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen 2')),
      body: Center(
        child: TextButton(
          onPressed: () => context.pushReplacement('/screen_1'),
          child: Text('Push Screen 1'),
        ),
      ),
    );
  }

}
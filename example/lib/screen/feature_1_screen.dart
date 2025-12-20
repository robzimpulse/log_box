import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Feature1Screen extends StatelessWidget {
  const Feature1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen 1')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => context.push('/screen_2'),
              child: Text('Push Screen 2'),
            ),
            TextButton(
              onPressed: () => context.push('/playground'),
              child: Text('Push Screen Playground'),
            ),
          ],
        ),
      ),
    );
  }

}
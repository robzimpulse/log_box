import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_box/log_box.dart';

class ShellScreen extends StatelessWidget {
  final StatefulNavigationShell shell;

  final LogBox box;

  const ShellScreen({super.key, required this.shell, required this.box});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        onTap: (index) {
          shell.goBranch(index, initialLocation: index == shell.currentIndex);
        },
      ),
      body: shell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => box.dashboard(context: context),
        child: const Icon(Icons.bug_report),
      ),
    );
  }
}

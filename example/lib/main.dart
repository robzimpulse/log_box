import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';

void main() {
  final box = LogBox(capacity: 100);
  final dio = Dio()..interceptors.add(box.interceptor);
  runApp(App(box: box, dio: dio));
}

class App extends StatelessWidget {
  const App({super.key, required this.box, required this.dio});

  final LogBox box;
  final Dio dio;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        observers: [box.observer],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return Home(title: 'Flutter Demo Home Page', box: box, dio: dio);
            },
          ),
        ],
      ),
    );
  }
}

class Home extends StatelessWidget {
  final String title;
  final LogBox box;
  final Dio dio;

  const Home({
    super.key,
    required this.title,
    required this.box,
    required this.dio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () => box.log('testing message'),
              child: Text('Send Log'),
            ),
            TextButton(
              onPressed: () async {
                final response = await dio.get('https://google.com');
                if (!context.mounted) return;
                final snackbar = SnackBar(content: Text(response.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              },
              child: Text('Send Get Request'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => box.dashboard(context: context),
        child: const Icon(Icons.bug_report),
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';

void main() {
  final box = LogBox(capacity: 100);
  final dio = Dio()..interceptors.add(box.interceptor);
  runApp(App(box: box, dio: dio));
}

class App extends StatelessWidget {
  const App({super.key, required this.box, required this.dio});

  final LogBox box;
  final Dio dio;

  ThemeData _themeLight() {
    return FlexThemeData.light(
      scheme: FlexScheme.outerSpace,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedHasBorder: false,
        appBarBackgroundSchemeColor: SchemeColor.primary,
        outlinedButtonRadius: 8,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: _themeLight(),
      routerConfig: GoRouter(
        observers: [box.observer],
        initialLocation: '/',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) {
              return Scaffold(
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: shell.currentIndex,
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: true,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Account',
                    ),
                  ],
                  onTap: (index) {
                    shell.goBranch(
                      index,
                      initialLocation: index == shell.currentIndex,
                    );
                  },
                ),
                body: shell,
                floatingActionButton: FloatingActionButton(
                  onPressed: () => box.dashboard(context: context),
                  child: const Icon(Icons.bug_report),
                ),
              );
            },
            branches: [
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/',
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Home')),
                        body: Center(
                          child: TextButton(
                            onPressed: () => context.push('/screen_1'),
                            child: Text('Push to Screen 1'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Search')),
                        body: Center(
                          child: TextButton(
                            onPressed: () => context.push('/screen_1'),
                            child: Text('Push to Screen 1'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/account',
                    builder: (context, state) {
                      return Scaffold(
                        appBar: AppBar(title: Text('Account')),
                        body: Center(
                          child: TextButton(
                            onPressed: () => context.push('/screen_1'),
                            child: Text('Push to Screen 1'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/screen_1',
            builder: (context, state) {
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
                        onPressed: () => context.push('/features'),
                        child: Text('Push Screen Feature'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/screen_2',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: Text('Screen 2')),
                body: Center(
                  child: TextButton(
                    onPressed: () => context.pushReplacement('/screen_1'),
                    child: Text('Push Screen 1'),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/features',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(title: Text('Screen 2')),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => box.log('testing message'),
                        child: Text('Send Log'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final response = await dio.get('https://google.com');
                          if (!context.mounted) return;
                          final snackbar = SnackBar(
                            content: Text(response.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        },
                        child: Text('Send Get Request'),
                      ),
                      TextButton(
                        onPressed: () {
                          box.webview(
                            context: context,
                            uri: Uri.parse('https://google.com/'),
                          );
                        },
                        child: Text('Open Webview'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// class Home extends StatelessWidget {
//   final String title;
//   final LogBox box;
//   final Dio dio;
//
//   const Home({
//     super.key,
//     required this.title,
//     required this.box,
//     required this.dio,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextButton(
//               onPressed: () => box.log('testing message'),
//               child: Text('Send Log'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 final response = await dio.get('https://google.com');
//                 if (!context.mounted) return;
//                 final snackbar = SnackBar(content: Text(response.toString()));
//                 ScaffoldMessenger.of(context).showSnackBar(snackbar);
//               },
//               child: Text('Send Get Request'),
//             ),
//             TextButton(
//               onPressed: () {
//                 box.webview(
//                   context: context,
//                   uri: Uri.parse('https://google.com'),
//                 );
//               },
//               child: Text('Open Webview'),
//             ),
//             TextButton(
//               onPressed: () => context.push('/screen_1'),
//               child: Text('Go to Screen 1'),
//             ),
//             TextButton(
//               onPressed: () => context.push('/screen_2'),
//               child: Text('Go to Screen 2'),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => box.dashboard(context: context),
//         child: const Icon(Icons.bug_report),
//       ),
//     );
//   }
// }

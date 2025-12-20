import 'package:dio/dio.dart';
import 'package:example/screen/feature_1_screen.dart';
import 'package:example/screen/feature_2_screen.dart';
import 'package:example/screen/home_screen.dart';
import 'package:example/screen/playground_screen.dart';
import 'package:example/screen/search_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';

import 'shell_screen.dart';
import 'webview_screen.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.box,
    required this.dio,
    required this.cache,
  });

  final LogBox box;
  final Dio dio;
  final BaseCacheManager cache;

  ThemeData _themeLight() {
    return FlexThemeData.light(
      scheme: FlexScheme.outerSpace,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useMaterial3Typography: true,
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
              return ShellScreen(shell: shell, box: box);
            },
            branches: [
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(path: '/', builder: (context, state) => HomeScreen()),
                ],
              ),
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (context, state) => SearchScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                observers: [box.observer],
                routes: [
                  GoRoute(
                    path: '/account',
                    builder: (context, state) => SearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/screen_1',
            builder: (context, state) => Feature1Screen(),
          ),
          GoRoute(
            path: '/screen_2',
            builder: (context, state) => Feature2Screen(),
          ),
          GoRoute(
            path: '/playground',
            builder: (context, state) {
              return PlaygroundScreen(box: box, dio: dio, cache: cache);
            },
          ),
          GoRoute(
            path: '/webview',
            builder: (context, state) {
              return WebviewScreen(
                uri: Uri.parse('https://toonclash.com'),
                observer: box.inAppWebviewObserver,
              );
            },
          ),
        ],
      ),
    );
  }
}

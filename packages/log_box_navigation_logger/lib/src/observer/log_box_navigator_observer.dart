import 'package:flutter/material.dart';

import '../enum/enum.dart';
import '../model/navigation_entry_model.dart';

class LogBoxNavigatorObserver extends NavigatorObserver {
  final ValueSetter<NavigationEntryModel> onEvent;

  LogBoxNavigatorObserver({required this.onEvent});

  @override
  void didPush(Route route, Route? previousRoute) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.push,
        route: route.settings.name,
        previousRoute: previousRoute?.settings.name,
      ),
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.pop,
        route: route.settings.name,
        previousRoute: previousRoute?.settings.name,
      ),
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.remove,
        route: route.settings.name,
        previousRoute: previousRoute?.settings.name,
      ),
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.replace,
        route: newRoute?.settings.name,
        previousRoute: oldRoute?.settings.name,
      ),
    );
  }
}
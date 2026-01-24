import 'package:flutter/material.dart';

import '../enum/enum.dart';
import '../model/navigation_entry_model.dart';
import '../extension/extension.dart';

class LogBoxNavigatorObserver extends NavigatorObserver {
  final ValueSetter<NavigationEntryModel> onEvent;

  LogBoxNavigatorObserver({required this.onEvent});

  @override
  void didPush(Route route, Route? previousRoute) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.push,
        route: route.settings.name,
        argument: route.settings.argumentString,
        previousRoute: previousRoute?.settings.name,
        previousArgument: previousRoute?.settings.argumentString,
      ),
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.pop,
        route: route.settings.name,
        argument: route.settings.argumentString,
        previousRoute: previousRoute?.settings.name,
        previousArgument: previousRoute?.settings.argumentString,
      ),
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.remove,
        route: route.settings.name,
        argument: route.settings.argumentString,
        previousRoute: previousRoute?.settings.name,
        previousArgument: previousRoute?.settings.argumentString,
      ),
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    onEvent(
      NavigationEntryModel(
        action: NavigationAction.replace,
        route: newRoute?.settings.name,
        argument: newRoute?.settings.argumentString,
        previousRoute: oldRoute?.settings.name,
        previousArgument: oldRoute?.settings.argumentString,
      ),
    );
  }
}

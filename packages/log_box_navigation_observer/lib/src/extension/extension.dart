import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';

import '../observer/log_box_navigator_observer.dart';

extension LogBoxNavigatorObserverExtension on LogBox {
  NavigatorObserver get observer {
    return LogBoxNavigatorObserver(
      onEvent: (event) {
        final route = event.route;
        final prev = event.previousRoute;
        final shouldSkip = [
          route == configuration['dashboard_route'],
          prev == configuration['detail_route'],
          route == configuration['detail_route'],
          prev == configuration['dashboard_route'],
        ].contains(true);

        if (shouldSkip) return;

        final name = event.previousRoute ?? configuration['prevRouteName'];

        storage.add(log: event.copyWith(previousRoute: name));
        if (event.route != null) configuration['prevRouteName'] = event.route;
      },
    );
  }
}

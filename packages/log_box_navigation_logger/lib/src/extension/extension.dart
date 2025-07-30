import 'package:flutter/material.dart';
import 'package:log_box/log_box.dart';

import '../observer/log_box_navigator_observer.dart';

extension LogBoxNavigatorObserverExtension on LogBox {
  NavigatorObserver get observer {
    return LogBoxNavigatorObserver(
      onEvent: (event) {
        final route = event.route;
        final prev = event.previousRoute;
        final names = routes.values.map((e) => e.name).nonNulls;
        final skip = names.contains(route) || names.contains(prev);
        if (skip) return;
        storage.add(log: event);
      },
    );
  }
}

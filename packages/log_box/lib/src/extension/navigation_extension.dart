
import 'package:flutter/material.dart';

import '../../log_box.dart';
import '../screen/dashboard_screen.dart';
import '../screen/detail_screen.dart';

extension NavigationExtension on LogBox {
  void dashboard({required BuildContext context, ThemeData? theme}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: routes.putIfAbsent(
          'dashboard_route',
          () => const RouteSettings(name: 'logbox/dashboard'),
        ),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: DashboardScreen(
              storage: storage,
              onTap: (item, keyword) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: routes.putIfAbsent(
                      'detail_route',
                      () => const RouteSettings(name: 'logbox/details'),
                    ),
                    builder: (context) {
                      return DetailScreen(
                        data: item,
                        box: this,
                        keyword: keyword,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

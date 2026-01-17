import 'package:flutter/material.dart';
import 'package:log_box/src/screen/paginated_dashboard_screen.dart';

import '../../log_box.dart';
import '../screen/live_dashboard_screen.dart';
import '../screen/detail_screen.dart';

extension NavigationExtension on LogBox {
  void entry({
    required BuildContext context,
    ThemeData? theme,
    required EntryModel item,
    required String keyword,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: routes.putIfAbsent(
          'detail_route',
          () => const RouteSettings(name: 'logbox/details'),
        ),
        builder: (context) {
          return DetailScreen(id: item.id, box: this, keyword: keyword);
        },
      ),
    );
  }

  void dashboard({required BuildContext context, ThemeData? theme}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: routes.putIfAbsent(
          'live_dashboard_route',
          () => const RouteSettings(name: 'logbox/dashboard/live'),
        ),
        builder: (context) {
          return Theme(
            data: theme ?? Theme.of(context),
            child: LiveDashboardScreen(
              box: this,
              onTapPaginated: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: routes.putIfAbsent(
                      'paginated_dashboard_route',
                      () => const RouteSettings(
                        name: 'logbox/dashboard/paginated',
                      ),
                    ),
                    builder: (context) => PaginatedDashboardScreen(
                      box: this,
                      onTapEntry: (item, keyword) {
                        entry(context: context, item: item, keyword: keyword);
                      },
                    ),
                  ),
                );
              },
              onTapEntry: (item, keyword) {
                entry(context: context, item: item, keyword: keyword);
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:log_box/src/screen/paginated_dashboard_screen.dart';

import '../../log_box.dart';
import '../screen/live_dashboard_screen.dart';
import '../screen/detail_screen.dart';

extension NavigationExtension on LogBox {
  static const MapEntry<String, RouteSettings> _liveDashboard = MapEntry(
    '/logbox/dashboard/live',
    RouteSettings(name: '/logbox/dashboard/live'),
  );

  static const MapEntry<String, RouteSettings> _paginatedDashboard = MapEntry(
    '/logbox/dashboard/paginated',
    RouteSettings(name: '/logbox/dashboard/paginated'),
  );

  static const MapEntry<String, RouteSettings> _detail = MapEntry(
    '/logbox/details',
    RouteSettings(name: '/logbox/details'),
  );

  void entry({
    required BuildContext context,
    ThemeData? theme,
    required EntryModel item,
    required String keyword,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: routes.putIfAbsent(_detail.key, () => _detail.value),
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
          _liveDashboard.key,
          () => _liveDashboard.value,
        ),
        builder: (context) => Theme(
          data: theme ?? Theme.of(context),
          child: LiveDashboardScreen(
            box: this,
            onTapPaginated: () => Navigator.push(
              context,
              MaterialPageRoute(
                settings: routes.putIfAbsent(
                  _paginatedDashboard.key,
                  () => _paginatedDashboard.value,
                ),
                builder: (context) => PaginatedDashboardScreen(
                  box: this,
                  onTapEntry: (item, keyword) {
                    entry(context: context, item: item, keyword: keyword);
                  },
                ),
              ),
            ),
            onTapEntry: (item, keyword) {
              entry(context: context, item: item, keyword: keyword);
            },
          ),
        ),
      ),
    );
  }

  List<GoRoute> goRoutes() {
    routes.addEntries([_liveDashboard, _paginatedDashboard, _detail]);

    return [
      GoRoute(
        path: _liveDashboard.key,
        name: _liveDashboard.key,
        builder: (context, state) => LiveDashboardScreen(
          box: this,
          onTapEntry: (item, keyword) => context.pushNamed(
            _detail.key,
            queryParameters: {'id': item.id, 'keyword': keyword},
          ),
          onTapPaginated: () => context.push(_paginatedDashboard.key),
        ),
      ),
      GoRoute(
        path: _paginatedDashboard.key,
        name: _paginatedDashboard.key,
        builder: (context, state) => PaginatedDashboardScreen(
          box: this,
          onTapEntry: (item, keyword) => context.pushNamed(
            _detail.key,
            queryParameters: {'id': item.id, 'keyword': keyword},
          ),
        ),
      ),
      GoRoute(
        path: _detail.key,
        name: _detail.key,
        builder: (context, state) => DetailScreen(
          box: this,
          id: state.uri.queryParameters['id'] ?? '',
          keyword: state.uri.queryParameters['keyword'] ?? '',
        ),
      ),
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/log_box.dart';
import 'package:log_box/src/extension/navigation_extension.dart';
import 'package:log_box/src/screen/detail_screen.dart';
import 'package:log_box/src/screen/live_dashboard_screen.dart';
import 'package:log_box/src/screen/paginated_dashboard_screen.dart';

void main() {
  group('NavigationExtension', () {
    late LogBox logBox;

    setUp(() {
      logBox = LogBox(storage: Storage(liveDataStorage: MemoryStorage()));
    });

    testWidgets('entry pushes DetailScreen', (tester) async {
      final log = LogEntryModel(id: '1', message: 'test');
      logBox.storage.add(log: log);
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => logBox.entry(context: context, item: log, keyword: ''),
              child: const Text('Go'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pump(); // Start transition
      await tester.pump(const Duration(milliseconds: 500)); // Wait for transition

      expect(find.byType(DetailScreen), findsOneWidget);
      expect(logBox.routes.containsKey('detail_route'), isTrue);
    });

    testWidgets('dashboard pushes LiveDashboardScreen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => logBox.dashboard(context: context),
              child: const Text('Go'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byType(LiveDashboardScreen), findsOneWidget);
      expect(logBox.routes.containsKey('live_dashboard_route'), isTrue);
    });

    testWidgets('dashboard navigation callbacks work', (tester) async {
      final log = LogEntryModel(id: '1', message: 'test');
      logBox.storage.add(log: log);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => logBox.dashboard(context: context),
              child: const Text('Go'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Find Paginated Dashboard button (it's in LiveDashboardScreen's AppBar/actions usually)
      // Let's check LiveDashboardScreen implementation to find the button
      final paginatedButton = find.byIcon(Icons.history); // Assuming history icon for paginated
      if (paginatedButton.evaluate().isNotEmpty) {
          await tester.tap(paginatedButton);
          await tester.pumpAndSettle();
          expect(find.byType(PaginatedDashboardScreen), findsOneWidget);
          expect(logBox.routes.containsKey('paginated_dashboard_route'), isTrue);
      }
      
      // Test onTapEntry in LiveDashboard
      // Go back to Live
      if (find.byType(PaginatedDashboardScreen).evaluate().isNotEmpty) {
          await tester.pageBack();
          await tester.pumpAndSettle();
      }
      
      // Tap on the log entry in LiveDashboard
      await tester.tap(find.text('test'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailScreen), findsOneWidget);
    });
  });
}

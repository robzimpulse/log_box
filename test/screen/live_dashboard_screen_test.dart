import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/log_box.dart';
import 'package:log_box/src/model/entry_model.dart';
import 'package:log_box/src/screen/live_dashboard_screen.dart';
import 'package:log_box/src/storage/base/live_data_storage.dart';
import 'package:log_box/src/storage/base/persistent_data_storage.dart';
import 'package:log_box/src/storage/storage.dart';
import 'package:mocktail/mocktail.dart';

class MockLogBox extends Mock implements LogBox {}
class MockStorage extends Mock implements Storage {}
class MockLiveDataStorage extends Mock implements LiveDataStorage {}
class MockPersistentDataStorage extends Mock implements PersistentDataStorage {}
class MockEntryModel extends Mock implements EntryModel {}
class EntryModelA extends MockEntryModel {}
class EntryModelB extends MockEntryModel {}
class FakeBuildContext extends Fake implements BuildContext {}

class FakeMapWithNull extends MapBase<String, Type> {
  @override
  Type? operator [](Object? key) => null;
  @override
  void operator []=(String key, Type value) {}
  @override
  void clear() {}
  @override
  Iterable<String> get keys => ['nullKey'];
  @override
  Type? remove(Object? key) => null;
}

void main() {
  late MockLogBox mockLogBox;
  late MockStorage mockStorage;
  late MockLiveDataStorage mockLiveStorage;
  late MockPersistentDataStorage mockPersistentStorage;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockLogBox = MockLogBox();
    mockStorage = MockStorage();
    mockLiveStorage = MockLiveDataStorage();
    mockPersistentStorage = MockPersistentDataStorage();

    when(() => mockLogBox.storage).thenReturn(mockStorage);
    when(() => mockStorage.liveStorage).thenReturn(mockLiveStorage);
    when(() => mockStorage.persistentStorage).thenReturn(null);

    // Default LiveDataStorage behaviors
    when(() => mockLiveStorage.types).thenReturn({});
    when(() => mockLiveStorage.data).thenReturn([]);
    when(() => mockLiveStorage.addListener(any())).thenAnswer((_) {});
    when(() => mockLiveStorage.removeListener(any())).thenAnswer((_) {});
  });

  Widget createWidget({
    void Function(EntryModel, String)? onTapEntry,
    VoidCallback? onTapPaginated,
  }) {
    return MaterialApp(
      home: LiveDashboardScreen(
        box: mockLogBox,
        onTapEntry: onTapEntry,
        onTapPaginated: onTapPaginated,
      ),
    );
  }

  testWidgets('displays "Log Dashboard" title initially', (tester) async {
    await tester.pumpWidget(createWidget());
    expect(find.text('Log Dashboard'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('toggles search mode and preserves controller text', (tester) async {
    await tester.pumpWidget(createWidget());
    
    // Open search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'persist');
    await tester.pump();

    // Close search
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    
    expect(find.text('Log Dashboard'), findsOneWidget);
    
    // Open search again - should have 'persist'
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'persist'), findsOneWidget);
  });

  testWidgets('updates keyword when typing in search field', (tester) async {
    await tester.pumpWidget(createWidget());
    
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();
    
    expect(find.text('No Data'), findsOneWidget);
  });

  testWidgets('displays "No Data" when empty', (tester) async {
    await tester.pumpWidget(createWidget());
    expect(find.text('No Data'), findsOneWidget);
  });

  testWidgets('displays logs and handles filtering', (tester) async {
    final entry1 = MockEntryModel();
    final entry2 = MockEntryModel();
    
    when(() => entry1.id).thenReturn('1');
    when(() => entry1.contains('test')).thenReturn(true);
    when(() => entry1.contains('')).thenReturn(true);
    when(() => entry1.tabLength(any())).thenReturn(1);
    when(() => entry1.title(any())).thenReturn(const Text('Log 1'));
    when(() => entry1.subtitle(any())).thenReturn(const Text('Subtitle 1'));

    when(() => entry2.id).thenReturn('2');
    when(() => entry2.contains('test')).thenReturn(false);
    when(() => entry2.contains('')).thenReturn(true);
    when(() => entry2.tabLength(any())).thenReturn(0);
    when(() => entry2.title(any())).thenReturn(const Text('Log 2'));
    when(() => entry2.subtitle(any())).thenReturn(const Text('Subtitle 2'));

    when(() => mockLiveStorage.data).thenReturn([entry1, entry2]);

    await tester.pumpWidget(createWidget());
    
    expect(find.text('Log 1'), findsOneWidget);
    expect(find.text('Log 2'), findsOneWidget);
    
    // Search for 'test'
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();
    
    expect(find.text('Log 1'), findsOneWidget);
    expect(find.text('Log 2'), findsNothing);
  });

  testWidgets('calls onTapEntry when log with detail is tapped', (tester) async {
    final entry = MockEntryModel();
    EntryModel? tappedEntry;
    String? tappedKeyword;

    when(() => entry.tabLength(any())).thenReturn(1);
    when(() => entry.title(any())).thenReturn(const Text('Log'));
    when(() => entry.subtitle(any())).thenReturn(const Text('Sub'));
    when(() => entry.contains(any())).thenReturn(true);
    when(() => mockLiveStorage.data).thenReturn([entry]);

    await tester.pumpWidget(createWidget(
      onTapEntry: (e, k) {
        tappedEntry = e;
        tappedKeyword = k;
      },
    ));

    await tester.tap(find.text('Log'));
    expect(tappedEntry, entry);
    expect(tappedKeyword, '');
  });

  testWidgets('does not call onTapEntry when log with no detail is tapped', (tester) async {
    final entry = MockEntryModel();
    bool tapped = false;

    when(() => entry.tabLength(any())).thenReturn(0);
    when(() => entry.title(any())).thenReturn(const Text('Log'));
    when(() => entry.subtitle(any())).thenReturn(const Text('Sub'));
    when(() => entry.contains(any())).thenReturn(true);
    when(() => mockLiveStorage.data).thenReturn([entry]);

    await tester.pumpWidget(createWidget(
      onTapEntry: (_, __) => tapped = true,
    ));

    await tester.tap(find.text('Log'));
    expect(tapped, false);
  });

  testWidgets('shows storage icon and calls onTapPaginated if persistentStorage exists', (tester) async {
    when(() => mockStorage.persistentStorage).thenReturn(mockPersistentStorage);
    bool paginatedTapped = false;

    await tester.pumpWidget(createWidget(
      onTapPaginated: () => paginatedTapped = true,
    ));

    final storageIcon = find.byIcon(Icons.storage);
    expect(storageIcon, findsOneWidget);
    
    await tester.tap(storageIcon);
    expect(paginatedTapped, true);
  });

  testWidgets('calls clear on liveStorage when delete icon is tapped', (tester) async {
    when(() => mockLiveStorage.clear()).thenReturn(null);
    
    await tester.pumpWidget(createWidget());
    
    await tester.tap(find.byIcon(Icons.delete));
    verify(() => mockLiveStorage.clear()).called(1);
  });

  testWidgets('handles type filtering', (tester) async {
    final entry1 = EntryModelA();
    final entry2 = EntryModelB();
    
    when(() => entry1.contains(any())).thenReturn(true);
    when(() => entry1.tabLength(any())).thenReturn(0);
    when(() => entry1.title(any())).thenReturn(const Text('Log 1'));
    when(() => entry1.subtitle(any())).thenReturn(const Text('Sub 1'));

    when(() => entry2.contains(any())).thenReturn(true);
    when(() => entry2.tabLength(any())).thenReturn(0);
    when(() => entry2.title(any())).thenReturn(const Text('Log 2'));
    when(() => entry2.subtitle(any())).thenReturn(const Text('Sub 2'));

    when(() => mockLiveStorage.types).thenReturn({
      'TypeA': EntryModelA,
      'TypeB': EntryModelB,
    });
    when(() => mockLiveStorage.data).thenReturn([entry1, entry2]);

    await tester.pumpWidget(createWidget());
    
    expect(find.text('TypeA'), findsOneWidget);
    expect(find.text('TypeB'), findsOneWidget);
    
    // Filter by TypeA
    await tester.tap(find.text('TypeA'));
    await tester.pump();
    
    expect(find.text('Log 1'), findsOneWidget);
    expect(find.text('Log 2'), findsNothing);
    
    // Deselect filter
    await tester.tap(find.text('TypeA'));
    await tester.pump();
    expect(find.text('Log 2'), findsOneWidget);
  });

  testWidgets('handles type with null value in map', (tester) async {
    when(() => mockLiveStorage.types).thenReturn(FakeMapWithNull());
    await tester.pumpWidget(createWidget());
    await tester.pump();
    expect(find.text('nullKey'), findsNothing);
  });

  testWidgets('PopScope handles pop correctly', (tester) async {
    await tester.pumpWidget(createWidget());
    
    // Enter search mode
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    // Find PopScope
    final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
    expect(popScopeFinder, findsAtLeast(1));
    final PopScope popScope = tester.widget(popScopeFinder.first);
    
    // success = false
    popScope.onPopInvokedWithResult!(false, null);
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Log Dashboard'), findsOneWidget);
    
    // success = true
    final PopScope popScopeAfter = tester.widget(find.byWidgetPredicate((w) => w is PopScope).first);
    popScopeAfter.onPopInvokedWithResult!(true, null);
    await tester.pump();
    expect(find.text('Log Dashboard'), findsOneWidget);
  });

  testWidgets('visual check for trailing chevron', (tester) async {
    final entry = MockEntryModel();
    when(() => entry.tabLength(any())).thenReturn(1);
    when(() => entry.title(any())).thenReturn(const Text('Log'));
    when(() => entry.subtitle(any())).thenReturn(const Text('Sub'));
    when(() => entry.contains(any())).thenReturn(true);
    when(() => mockLiveStorage.data).thenReturn([entry]);

    await tester.pumpWidget(createWidget());
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}

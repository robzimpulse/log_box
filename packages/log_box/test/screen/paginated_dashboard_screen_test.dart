import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/log_box.dart';
import 'package:log_box/src/model/entry_model.dart';
import 'package:log_box/src/screen/paginated_dashboard_screen.dart';
import 'package:log_box/src/storage/base/persistent_data_storage.dart';
import 'package:log_box/src/storage/storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:super_paging/super_paging.dart';

class MockLogBox extends Mock implements LogBox {}
class MockStorage extends Mock implements Storage {}
class MockPersistentDataStorage extends Mock implements PersistentDataStorage {}
class MockEntryModel extends Mock implements EntryModel {}
class FakeBuildContext extends Fake implements BuildContext {}

class FakeMapWithNull extends MapBase<String, Type> {
  @override
  Type? operator [](Object? key) => null;
  @override
  void operator []=(String key, Type value) {}
  @override
  void clear() {}
  @override
  Iterable<String> get keys => ['NullType'];
  @override
  Type? remove(Object? key) => null;
}

void main() {
  late MockLogBox mockLogBox;
  late MockStorage mockStorage;
  late MockPersistentDataStorage mockPersistentStorage;
  late StreamController<Map<String, Type>> typesController;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(const Cursor());
    registerFallbackValue(LoadParams<Cursor>(key: null, loadSize: 20, loadType: LoadType.refresh));
  });

  setUp(() {
    mockLogBox = MockLogBox();
    mockStorage = MockStorage();
    mockPersistentStorage = MockPersistentDataStorage();
    typesController = StreamController<Map<String, Type>>.broadcast();

    when(() => mockLogBox.storage).thenReturn(mockStorage);
    when(() => mockStorage.persistentStorage).thenReturn(mockPersistentStorage);
    when(() => mockPersistentStorage.types).thenAnswer((_) => typesController.stream);
    
    when(() => mockPersistentStorage.load(any())).thenAnswer((_) async {
      return LoadResult.page(items: [], nextKey: null, prevKey: null);
    });
  });

  tearDown(() {
    typesController.close();
  });

  Widget createWidget({
    void Function(EntryModel, String)? onTapEntry,
  }) {
    return MaterialApp(
      home: PaginatedDashboardScreen(
        box: mockLogBox,
        onTapEntry: onTapEntry,
      ),
    );
  }

  Future<void> pumpNTimes(WidgetTester tester, {int n = 5}) async {
    for (int i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('displays "Log Dashboard" title initially', (tester) async {
    await tester.pumpWidget(createWidget());
    expect(find.text('Log Dashboard'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await pumpNTimes(tester);
  });

  testWidgets('toggles search mode', (tester) async {
    await tester.pumpWidget(createWidget());
    
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    
    expect(find.byType(TextField), findsOneWidget);
    
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    
    expect(find.text('Log Dashboard'), findsOneWidget);
    await pumpNTimes(tester);
  });

  testWidgets('clears keyword when closing search', (tester) async {
    await tester.pumpWidget(createWidget());
    
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();
    
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, '');
    await pumpNTimes(tester);
  });

  testWidgets('triggers refresh on search submit', (tester) async {
    await tester.pumpWidget(createWidget());
    
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    
    await tester.enterText(find.byType(TextField), 'search query');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpNTimes(tester);

    verify(() => mockPersistentStorage.load(any())).called(greaterThan(0));
  });

  testWidgets('calls clear on persistentStorage when delete icon is tapped', (tester) async {
    when(() => mockPersistentStorage.clear()).thenAnswer((_) async {});
    
    await tester.pumpWidget(createWidget());
    
    await tester.tap(find.byIcon(Icons.delete));
    verify(() => mockPersistentStorage.clear()).called(1);
    await pumpNTimes(tester);
  });

  testWidgets('handles types stream: loading, data, error', (tester) async {
    await tester.pumpWidget(createWidget());
    
    expect(find.byType(CircularProgressIndicator), findsAtLeast(1));

    typesController.add({'TypeA': String, 'TypeB': int});
    await tester.pump();
    
    expect(find.text('TypeA'), findsOneWidget);
    expect(find.text('TypeB'), findsOneWidget);

    typesController.addError('Stream Error');
    await tester.pump();
    expect(find.text('Stream Error'), findsOneWidget);
    await pumpNTimes(tester);
  });

  testWidgets('toggles type selection and refreshes', (tester) async {
    await tester.pumpWidget(createWidget());
    typesController.add({'TypeA': String});
    await tester.pump();
    await tester.pump();

    expect(find.text('TypeA'), findsOneWidget);
    await tester.tap(find.text('TypeA'));
    await pumpNTimes(tester);
    
    final buttonFinder = find.widgetWithText(OutlinedButton, 'TypeA');
    final button = tester.widget<OutlinedButton>(buttonFinder);
    expect(button.style?.backgroundColor?.resolve({}), Colors.grey);

    // Initial load happens, plus refresh after selecting type
    verify(() => mockPersistentStorage.load(any())).called(greaterThan(0));

    await tester.tap(find.text('TypeA'));
    await pumpNTimes(tester);
    final buttonAfter = tester.widget<OutlinedButton>(buttonFinder);
    expect(buttonAfter.style?.backgroundColor?.resolve({}), isNull);
  });

  testWidgets('displays "No Data Found" when empty and handles refresh button', (tester) async {
    await tester.pumpWidget(createWidget());
    await pumpNTimes(tester);
    
    expect(find.text('No Data Found'), findsOneWidget);
    
    await tester.tap(find.text('Refresh'));
    await tester.pump();
    
    verify(() => mockPersistentStorage.load(any())).called(greaterThan(0));
    await pumpNTimes(tester);
  });

  testWidgets('displays error in content', (tester) async {
    when(() => mockPersistentStorage.load(any())).thenAnswer((_) async {
      return LoadResult.error(Exception('Load Failed'));
    });

    await tester.pumpWidget(createWidget());
    await pumpNTimes(tester);
    
    expect(find.text('Exception: Load Failed'), findsOneWidget);
    await pumpNTimes(tester);
  });

  testWidgets('displays loading in content', (tester) async {
    final completer = Completer<LoadResult<Cursor, EntryModel>>();
    when(() => mockPersistentStorage.load(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createWidget());
    await tester.pump();
    
    expect(find.byType(CircularProgressIndicator), findsAtLeast(1));

    completer.complete(LoadResult.page(items: [], nextKey: null, prevKey: null));
    await pumpNTimes(tester);
  });

  testWidgets('displays items and handles tap', (tester) async {
    final entry = MockEntryModel();
    when(() => entry.id).thenReturn('1');
    when(() => entry.tabLength(any())).thenReturn(1);
    when(() => entry.title(any())).thenReturn(const Text('Entry Title'));
    when(() => entry.subtitle(any())).thenReturn(const Text('Entry Subtitle'));

    when(() => mockPersistentStorage.load(any())).thenAnswer((_) async {
      return LoadResult.page(items: [entry], nextKey: null, prevKey: null);
    });

    EntryModel? tappedEntry;
    await tester.pumpWidget(createWidget(onTapEntry: (e, k) => tappedEntry = e));
    await pumpNTimes(tester);

    expect(find.text('Entry Title'), findsOneWidget);
    
    await tester.tap(find.text('Entry Title'));
    expect(tappedEntry, entry);
  });

  testWidgets('does not call onTapEntry if no detail', (tester) async {
    final entry = MockEntryModel();
    when(() => entry.id).thenReturn('1');
    when(() => entry.tabLength(any())).thenReturn(0);
    when(() => entry.title(any())).thenReturn(const Text('Entry Title'));
    when(() => entry.subtitle(any())).thenReturn(const Text('Entry Subtitle'));

    when(() => mockPersistentStorage.load(any())).thenAnswer((_) async {
      return LoadResult.page(items: [entry], nextKey: null, prevKey: null);
    });

    bool tapped = false;
    await tester.pumpWidget(createWidget(onTapEntry: (e, k) => tapped = true));
    await pumpNTimes(tester);

    await tester.tap(find.text('Entry Title'));
    expect(tapped, false);
  });

  testWidgets('PopScope handles pop and toggles search', (tester) async {
    await tester.pumpWidget(createWidget());
    
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
    final PopScope popScope = tester.widget(popScopeFinder);
    
    popScope.onPopInvokedWithResult!(false, null);
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Log Dashboard'), findsOneWidget);
    await pumpNTimes(tester);
  });

  testWidgets('displays "No Data" when types stream is empty', (tester) async {
    await tester.pumpWidget(createWidget());
    typesController.add({});
    await tester.pump();
    expect(find.text('No Data'), findsOneWidget);
    await pumpNTimes(tester);
  });

  testWidgets('displays "No Data" when pager is null (no persistent storage)', (tester) async {
    when(() => mockStorage.persistentStorage).thenReturn(null);
    await tester.pumpWidget(createWidget());
    expect(find.text('No Data'), findsOneWidget);
    expect(find.byType(BidirectionalPagingListView), findsNothing);
    await pumpNTimes(tester);
  });

  testWidgets('handles null type in types map', (tester) async {
    await tester.pumpWidget(createWidget());
    typesController.add(FakeMapWithNull());
    await tester.pump();
    expect(find.text('NullType'), findsNothing);
    await pumpNTimes(tester);
  });

  testWidgets('updates keyword when typing', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    
    await tester.enterText(find.byType(TextField), 'new keyword');
    await tester.pump();
    
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await pumpNTimes(tester);
    
    verify(() => mockPersistentStorage.load(any())).called(greaterThan(0));
  });
}

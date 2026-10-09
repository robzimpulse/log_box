import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_box/src/log_box.dart';
import 'package:log_box/src/model/entry_model.dart';
import 'package:log_box/src/screen/detail_screen.dart';
import 'package:log_box/src/storage/storage.dart';
import 'package:mocktail/mocktail.dart';

class MockLogBox extends Mock implements LogBox {}
class MockStorage extends Mock implements Storage {}
class MockEntryModel extends Mock implements EntryModel {}
class FakeBuildContext extends Fake implements BuildContext {}
class FakeRoute extends Fake implements Route<dynamic> {}
class FakeLogBox extends Fake implements LogBox {}

void main() {
  late MockLogBox mockLogBox;
  late MockStorage mockStorage;
  late MockEntryModel mockEntryModel;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(const Tab(text: ''));
    registerFallbackValue(FakeRoute());
    registerFallbackValue(FakeLogBox());
  });

  setUp(() {
    mockLogBox = MockLogBox();
    mockStorage = MockStorage();
    mockEntryModel = MockEntryModel();

    when(() => mockLogBox.storage).thenReturn(mockStorage);
    
    // Default behaviors for EntryModel
    when(() => mockEntryModel.tabLength(any())).thenReturn(1);
    when(() => mockEntryModel.tabs(any(), searchTerm: any(named: 'searchTerm')))
        .thenReturn({const Tab(text: 'Tab 1'): const Text('Content 1')});
    when(() => mockEntryModel.menus(any(), any())).thenReturn([]);
  });

  Widget createWidget({
    String id = '1',
    String keyword = '',
    required Stream<EntryModel> stream,
  }) {
    when(() => mockStorage.stream(id)).thenAnswer((_) => stream);
    return MaterialApp(
      home: DetailScreen(
        id: id,
        box: mockLogBox,
        keyword: keyword,
      ),
    );
  }

  testWidgets('displays loading state initially', (tester) async {
    final controller = StreamController<EntryModel>();
    await tester.pumpWidget(createWidget(stream: controller.stream));
    expect(find.text('Loading'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await controller.close();
  });

  testWidgets('displays error state', (tester) async {
    final controller = StreamController<EntryModel>();
    await tester.pumpWidget(createWidget(stream: controller.stream));
    controller.addError('Something went wrong');
    await tester.pump();

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Something went wrong'), findsOneWidget);
    await controller.close();
  });

  testWidgets('displays no data state', (tester) async {
    await tester.pumpWidget(createWidget(stream: Stream.empty()));
    await tester.pump();

    expect(find.text('No Data'), findsNWidgets(2));
  });

  testWidgets('displays content when data is available', (tester) async {
    await tester.pumpWidget(createWidget(stream: Stream.value(mockEntryModel)));
    await tester.pump();

    expect(find.text('Detail Log'), findsOneWidget);
    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Content 1'), findsOneWidget);
  });

  testWidgets('toggles search mode and unfocuses', (tester) async {
    await tester.pumpWidget(createWidget(stream: Stream.value(mockEntryModel)));
    await tester.pump();

    // Enter search mode
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    
    // Exit search mode
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(find.text('Detail Log'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    
    // Verify tabs called with null searchTerm when search is closed
    verify(() => mockEntryModel.tabs(any(), searchTerm: null)).called(greaterThan(0));
  });

  testWidgets('updates to empty keyword in didUpdateWidget', (tester) async {
    final key = GlobalKey();
    when(() => mockStorage.stream('1')).thenAnswer((_) => Stream.value(mockEntryModel));

    await tester.pumpWidget(MaterialApp(
      home: DetailScreen(
        key: key,
        id: '1',
        box: mockLogBox,
        keyword: 'something',
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: DetailScreen(
        key: key,
        id: '1',
        box: mockLogBox,
        keyword: '',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Detail Log'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('preserves search controller text when toggling search', (tester) async {
    await tester.pumpWidget(createWidget(stream: Stream.value(mockEntryModel)));
    await tester.pumpAndSettle();

    // Enter search mode and type
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'persist');
    await tester.pump();

    // Exit search mode
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    
    // Enter search mode again
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    expect(find.widgetWithText(TextField, 'persist'), findsOneWidget);
    verify(() => mockEntryModel.tabs(any(), searchTerm: 'persist')).called(greaterThan(0));
  });

  testWidgets('updates keyword when typing in search field', (tester) async {
    await tester.pumpWidget(createWidget(stream: Stream.value(mockEntryModel)));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'test query');
    await tester.pump();

    verify(() => mockEntryModel.tabs(any(), searchTerm: 'test query')).called(greaterThan(0));
  });

  testWidgets('initializes with keyword and starts in search mode', (tester) async {
    await tester.pumpWidget(createWidget(keyword: 'initial', stream: Stream.value(mockEntryModel)));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(TextField, 'initial'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('updates when widget keyword changes', (tester) async {
    final key = GlobalKey();
    
    when(() => mockStorage.stream('1')).thenAnswer((_) => Stream.value(mockEntryModel));

    await tester.pumpWidget(MaterialApp(
      home: DetailScreen(
        key: key,
        id: '1',
        box: mockLogBox,
        keyword: 'first',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, 'first');

    await tester.pumpWidget(MaterialApp(
      home: DetailScreen(
        key: key,
        id: '1',
        box: mockLogBox,
        keyword: 'second',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, 'second');
  });

  testWidgets('pops navigator when back button is pressed', (tester) async {
    final observer = MockNavigatorObserver();
    when(() => mockStorage.stream('1')).thenAnswer((_) => Stream.value(mockEntryModel));

    await tester.pumpWidget(MaterialApp(
      navigatorObservers: [observer],
      home: DetailScreen(id: '1', box: mockLogBox),
    ));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    verify(() => observer.didPop(any(), any())).called(1);
  });

  testWidgets('renders custom menus from EntryModel', (tester) async {
    when(() => mockEntryModel.menus(any(), any())).thenReturn([
      const IconButton(onPressed: null, icon: Icon(Icons.share)),
    ]);

    await tester.pumpWidget(createWidget(stream: Stream.value(mockEntryModel)));
    await tester.pump();

    expect(find.byIcon(Icons.share), findsOneWidget);
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

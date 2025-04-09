import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/screens/bookDetail/edit_book_page.dart';
import '../mocks/service_mocks.mocks.dart';
import 'package:pocketbase/pocketbase.dart';

@GenerateMocks([
  PocketBase,
  RecordService,
  RecordModel,
  ResultList,
])
void main() {
  late MockUserService mockUserService;
  late MockPocketBase mockPocketBase;
  late MockRecordService mockRecordService;
  late MockPocketbaseRecord mockRecord;
  late BookDetailsController controller;
  late BookModel testBook;

  setUp(() {
    mockUserService = MockUserService();
    mockPocketBase = MockPocketBase();
    mockRecordService = MockRecordService();
    mockRecord = MockPocketbaseRecord();
    testBook = BookModel(
      id: '1',
      title: 'Test Book',
      description: 'Test Description',
      genre: ['Fantasy'],
      bookType: 'Novel',
      author: 'author1',
      coverImage: 'cover.jpg',
    );

    // Stub PocketBase collections
    when(mockPocketBase.collection('chapters')).thenReturn(mockRecordService);
    when(mockPocketBase.collection('books')).thenReturn(mockRecordService);
    when(mockRecordService.getFirstListItem('select=description')).thenAnswer((_) async => mockRecord);
    
    final mockResultList = MockResultList();
    when(mockResultList.items).thenReturn([mockRecord]);
    when(mockRecordService.getList(filter: anyNamed('filter'))).thenAnswer((_) async => mockResultList);
    
    when(mockRecord.toJson()).thenReturn({'description': 'Test Description'});

    controller = BookDetailsController(
      userService: mockUserService,
      pb: mockPocketBase,
      bookId: '1',
    );

    Get.put(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('EditBookPage displays initial book data correctly', (WidgetTester tester) async {
    controller.book.value = testBook;

    await tester.pumpWidget(
      MaterialApp(
        home: EditBookPage(book: testBook),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Test Book'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('Fantasy'), findsOneWidget);
    expect(find.text('Novel'), findsOneWidget);
  });

  testWidgets('EditBookPage validates empty title', (WidgetTester tester) async {
    controller.book.value = testBook;

    await tester.pumpWidget(
      MaterialApp(
        home: EditBookPage(book: testBook),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('titleField')), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
  });

  testWidgets('EditBookPage validates empty description', (WidgetTester tester) async {
    controller.book.value = testBook;

    await tester.pumpWidget(
      MaterialApp(
        home: EditBookPage(book: testBook),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('descriptionField')), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a description'), findsOneWidget);
  });

  testWidgets('EditBookPage allows genre selection', (WidgetTester tester) async {
    controller.book.value = testBook;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditBookPage(book: testBook),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('genreDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Science Fiction').last);
    await tester.pumpAndSettle();

    expect(find.text('Science Fiction'), findsOneWidget);
  });

  testWidgets('EditBookPage handles successful update', (WidgetTester tester) async {
    controller.book.value = testBook;
    when(mockRecordService.update(
      any,
      body: anyNamed('body'),
    )).thenAnswer((_) async => mockRecord);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditBookPage(book: testBook),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('titleField')), 'Updated Title');
    await tester.enterText(find.byKey(const Key('descriptionField')), 'Updated Description');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(mockRecordService.update(
      any,
      body: captureAnyNamed('body'),
    )).called(1);
  });

  testWidgets('EditBookPage handles update failure', (WidgetTester tester) async {
    controller.book.value = testBook;
    when(mockRecordService.update(
      any,
      body: anyNamed('body'),
    )).thenThrow(Exception('Update failed'));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EditBookPage(book: testBook),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('titleField')), 'Updated Title');
    await tester.enterText(find.byKey(const Key('descriptionField')), 'Updated Description');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to update book: Exception: Update failed'), findsOneWidget);
  });
} 
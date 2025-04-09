import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/models/chapter_model.dart';
import '../mocks/service_mocks.mocks.dart';

void main() {
  late BookDetailsController controller;
  late MockUserService mockUserService;
  late MockPocketBase mockPocketBase;
  late MockRecordService mockRecordService;
  late MockPocketbaseRecord mockRecord;
  late MockBookModel mockBookModel;
  late MockChapterModel mockChapterModel;

  const String testBookId = 'test_book_id';
  const String testUserId = 'test_user_id';

  setUp(() {
    mockUserService = MockUserService();
    mockPocketBase = MockPocketBase();
    mockRecordService = MockRecordService();
    mockRecord = MockPocketbaseRecord();
    mockBookModel = MockBookModel();
    mockChapterModel = MockChapterModel();

    // Setup default mock behaviors
    when(mockUserService.getUserId()).thenAnswer((_) async => testUserId);
    when(mockPocketBase.collection('books')).thenReturn(mockRecordService);
    when(mockPocketBase.collection('chapters')).thenReturn(mockRecordService);
    when(mockRecord.toJson()).thenReturn({});

    controller = BookDetailsController(
      userService: mockUserService,
      bookId: testBookId,
      pb: mockPocketBase,
    );
  });

  group('Initialization', () {
    test('should initialize with correct values', () {
      expect(controller.bookId, equals(testBookId));
      expect(controller.book.value, isNull);
      expect(controller.chapters, isEmpty);
      expect(controller.isLoading.value, isFalse);
      expect(controller.hasDescription.value, isFalse);
      expect(controller.description.value, isNull);
    });

    test('should fetch user ID on init', () async {
      await controller.onInit();
      verify(mockUserService.getUserId()).called(1);
      expect(controller.userId, equals(testUserId));
    });
  });

  group('Book Details', () {
    test('should fetch book details successfully', () async {
      when(mockRecordService.getOne(testBookId))
          .thenAnswer((_) async => mockRecord);
      
      await controller.fetchBookDetails();
      
      verify(mockRecordService.getOne(testBookId)).called(1);
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage?.value, isNull);
    });

    test('should handle error when fetching book details', () async {
      when(mockRecordService.getOne(testBookId))
          .thenThrow(Exception('Network error'));
      
      await controller.fetchBookDetails();
      
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage?.value, contains('Failed to fetch book details'));
    });
  });

  group('Description Management', () {
    test('should fetch description successfully', () async {
      when(mockRecordService.getFirstListItem(any))
          .thenAnswer((_) async => mockRecord);
      
      await controller.fetchDescription();
      
      expect(controller.hasDescription.value, isTrue);
      verify(mockRecordService.getFirstListItem(any)).called(1);
    });

    test('should handle missing description', () async {
      when(mockRecordService.getFirstListItem(any))
          .thenThrow(ClientException(message: 'Not found', statusCode: 404, response: {}));
      
      await controller.fetchDescription();
      
      expect(controller.hasDescription.value, isFalse);
      expect(controller.description.value, isNull);
    });
  });

  group('Chapter Management', () {
    test('should fetch chapters successfully', () async {
      final listResult = RecordList([],
        page: 1,
        perPage: 50,
        totalItems: 1,
        totalPages: 1,
      );
      
      when(mockRecordService.getList(
        filter: anyNamed('filter'),
        sort: anyNamed('sort'),
      )).thenAnswer((_) async => listResult);
      
      await controller.fetchChapters();
      
      verify(mockRecordService.getList(
        filter: anyNamed('filter'),
        sort: anyNamed('sort'),
      )).called(1);
    });

    test('should get next chapter order number', () async {
      final listResult = RecordList([mockRecord],
        page: 1,
        perPage: 50,
        totalItems: 1,
        totalPages: 1,
      );
      
      when(mockRecord.data).thenReturn({'order_number': 5});
      when(mockRecordService.getList(
        filter: anyNamed('filter'),
        sort: anyNamed('sort'),
        perPage: anyNamed('perPage'),
      )).thenAnswer((_) async => listResult);
      
      final nextNumber = await controller.getNextChapterOrderNumber();
      
      expect(nextNumber, equals(6));
    });
  });
} 
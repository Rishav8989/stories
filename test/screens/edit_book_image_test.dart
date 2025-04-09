import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/screens/bookDetail/edit_book_page.dart';
import '../mocks/service_mocks.mocks.dart';

// Mock ImagePicker
class MockImagePicker extends Mock implements ImagePicker {
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    return XFile('test/resources/test_image.jpg');
  }
}

void main() {
  late BookDetailsController controller;
  late MockUserService mockUserService;
  late MockPocketBase mockPb;
  late BookModel testBook;
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockUserService = MockUserService();
    mockPb = MockPocketBase();
    mockImagePicker = MockImagePicker();
    when(mockUserService.getUserId()).thenAnswer((_) async => 'test_user_id');

    testBook = BookModel(
      id: 'test_book_id',
      title: 'Test Book',
      description: 'Test Description',
      genre: ['Fantasy'],
      bookType: 'Novel',
      author: 'test_user_id',
    );

    controller = BookDetailsController(
      bookId: testBook.id,
      userService: mockUserService,
      pb: mockPb,
    );

    Get.put(controller, tag: testBook.id);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('EditBookPage allows image selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditBookPage(book: testBook),
      ),
    );

    // Find and tap the change cover image button
    await tester.tap(find.text('Change Cover Image'));
    await tester.pumpAndSettle();

    // Verify that the image picker was shown
    verify(mockImagePicker.pickImage(
      source: ImageSource.gallery,
    )).called(1);
  });

  testWidgets('EditBookPage handles image update successfully',
      (WidgetTester tester) async {
    final mockRecordService = MockRecordService();
    when(mockPb.collection('books')).thenReturn(mockRecordService);

    final mockRecord = MockPocketbaseRecord();
    when(mockRecord.toJson()).thenReturn({
      'id': 'test_book_id',
      'title': 'Test Book',
      'description': 'Test Description',
      'Genre': ['Fantasy'],
      'book_type': 'Novel',
      'book_cover': 'new_image.jpg',
    });

    // Mock successful image upload
    when(mockRecordService.update('test_book_id', body: anyNamed('body')))
        .thenAnswer((_) async => mockRecord);

    await tester.pumpWidget(
      MaterialApp(
        home: EditBookPage(book: testBook),
      ),
    );

    // Select a new image
    await tester.tap(find.text('Change Cover Image'));
    await tester.pumpAndSettle();

    // Save the changes
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify that the update was called with the image
    verify(mockRecordService.update('test_book_id', body: anyNamed('body')))
        .called(1);
  });

  testWidgets('EditBookPage handles image update failure',
      (WidgetTester tester) async {
    final mockRecordService = MockRecordService();
    when(mockPb.collection('books')).thenReturn(mockRecordService);

    // Mock failed image upload
    when(mockRecordService.update('test_book_id', body: anyNamed('body')))
        .thenThrow(Exception('Failed to upload image'));

    await tester.pumpWidget(
      MaterialApp(
        home: EditBookPage(book: testBook),
      ),
    );

    // Select a new image
    await tester.tap(find.text('Change Cover Image'));
    await tester.pumpAndSettle();

    // Try to save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify error snackbar is shown
    expect(find.text('Failed to update book: Exception: Failed to upload image'),
        findsOneWidget);
  });

  testWidgets('EditBookPage shows selected image preview',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditBookPage(book: testBook),
      ),
    );

    // Select a new image
    await tester.tap(find.text('Change Cover Image'));
    await tester.pumpAndSettle();

    // Verify that the selected image is displayed
    expect(find.byType(Image), findsOneWidget);
  });
} 
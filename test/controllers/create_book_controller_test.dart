import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stories/controller/create_book_controller.dart';

void main() {
  late CreateBookController createBookController;

  setUp(() {
    createBookController = CreateBookController();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('CreateBookController Tests', () {
    test('initial values should be correct', () {
      expect(createBookController.isLoading.value, false);
      expect(createBookController.selectedGenre.value, isNull);
      expect(createBookController.bookCover.value, isNull);
      expect(createBookController.genres, isNotEmpty);
    });

    test('resetForm should clear all fields', () {
      createBookController.titleController.text = 'Test Book';
      createBookController.selectedGenre.value = 'Fantasy';
      
      createBookController.resetForm();
      
      expect(createBookController.titleController.text, isEmpty);
      expect(createBookController.selectedGenre.value, isNull);
      expect(createBookController.bookCover.value, isNull);
    });
  });
}
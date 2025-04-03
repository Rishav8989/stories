import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:stories/utils/user_service.dart';

class BookDetailsController extends GetxController {
  final isLoading = true.obs;
  final Rx<Book?> book = Rx<Book?>(null);
  String? errorMessage;
  String? userId;
  final String bookId;
  
  final UserService _userService;
  
  BookDetailsController({required this.bookId}) 
      : _userService = UserService(PocketBase(dotenv.get('POCKETBASE_URL')));

  @override
  void onInit() {
    super.onInit();
    _initializeUserId();
    fetchBookDetails();
  }

  Future<void> _initializeUserId() async {
    userId = await _userService.getUserId();
  }

  Future<void> fetchBookDetails() async {
    try {
      final record = await _userService.pb.collection('books').getOne(
        bookId,
        expand: 'author',
      );

      book.value = Book.fromJson(record.data);
      isLoading.value = false;
    } catch (e) {
      errorMessage = 'Failed to load book details';
      isLoading.value = false;
    }
  }

  Future<void> publishBook() async {
    try {
      isLoading.value = true;
      
      // Only allow publishing if book is in draft status
      if (book.value?.status != 'draft') {
        return;
      }

      final bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Publish Book'),
          content: const Text('Are you sure you want to publish this book? Published books will be visible to all users.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
              child: const Text('Publish'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));
      await pb.collection('books').update(
        bookId,
        body: {
          "status": "published",
        },
      );

      await fetchBookDetails(); // Refresh book details

      Get.snackbar(
        'Success',
        'Book published successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate back to create page
      Get.back();

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to publish book: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBook() async {
    try {
      isLoading.value = true;
      await _userService.pb.collection('books').delete(bookId);
    } finally {
      isLoading.value = false;
    }
  }
}
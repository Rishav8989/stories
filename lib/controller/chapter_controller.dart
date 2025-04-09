import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

class ChapterController extends GetxController {
  final isLoading = false.obs;
  final UserService _userService;
  
  ChapterController() : _userService = UserService(PocketBase(dotenv.get('POCKETBASE_URL')));

  Future<bool> isBookOwner(String bookId) async {
    try {
      final userId = await _userService.getUserId();
      final book = await _userService.pb.collection('books').getOne(bookId);
      return book.data['author'] == userId;
    } catch (e) {
      print("Error checking book ownership: $e");
      return false;
    }
  }

  Future<int> getNextOrderNumber(String bookId) async {
    try {
      final chapters = await _userService.pb
          .collection('chapters')
          .getList(
            filter: 'book = "$bookId"',
            sort: '-order_number',
            perPage: 1,
          );
      
      if (chapters.items.isEmpty) {
        return 1; // First chapter
      }
      
      final lastChapter = chapters.items.first;
      final lastOrderNumber = lastChapter.data['order_number'] as int;
      return lastOrderNumber + 1;
    } catch (e) {
      print("Error getting next order number: $e");
      return 1; // Fallback to 1 if there's an error
    }
  }

  Future<void> createChapter({
    required String bookId,
    required String title,
    required String content,
    String type = 'content',
  }) async {
    if (!await isBookOwner(bookId)) {
      Get.snackbar('Error', 'Only the book author can add chapters', backgroundColor: Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      final orderNumber = await getNextOrderNumber(bookId);
      
      await _userService.pb.collection('chapters').create(body: {
        "book": bookId,
        "title": title,
        "content": content,
        "status": "draft",
        "type": type,
        "order_number": orderNumber,
      });
      
      // Refresh the chapters list in the book details controller
      final bookDetailsController = Get.find<BookDetailsController>();
      await bookDetailsController.fetchChapters();
      
      Get.back(); // Return to previous screen
      Get.snackbar('Success', 'Chapter added successfully!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error creating chapter: $e");
      Get.snackbar('Error', 'Failed to add chapter: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> publishChapter(String chapterId) async {
    try {
      await _userService.pb.collection('chapters').update(chapterId, body: {
        "status": "published",
      });
      
      // Refresh the chapters list in the book details controller
      final bookDetailsController = Get.find<BookDetailsController>();
      await bookDetailsController.fetchChapters();
      
      Get.back(); // Return to previous screen
      Get.snackbar('Success', 'Chapter published successfully!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error publishing chapter: $e");
      Get.snackbar('Error', 'Failed to publish chapter: $e', backgroundColor: Colors.red);
    }
  }

  Future<List<Map<String, dynamic>>> getChapters(String bookId) async {
    try {
      final records = await _userService.pb
          .collection('chapters')
          .getList(
            filter: 'book = "$bookId"',
            sort: 'order_number',
          );
      return records.items.map((record) => record.data).toList();
    } catch (e) {
      print("Error fetching chapters: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPublishedChapters(String bookId) async {
    try {
      final records = await _userService.pb
          .collection('chapters')
          .getList(
            filter: 'book = "$bookId" && status = "published"',
            sort: 'order_number',
          );
      return records.items.map((record) => record.data).toList();
    } catch (e) {
      print("Error fetching published chapters: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getChapterContent(String chapterId) async {
    try {
      final record = await _userService.pb
          .collection('chapters')
          .getOne(chapterId);
      return record.data;
    } catch (e) {
      print("Error fetching chapter content: $e");
      rethrow;
    }
  }
} 
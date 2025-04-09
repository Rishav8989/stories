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

  Future<void> createChapter({
    required String bookId,
    required String title,
    required String content,
    required int orderNumber,
  }) async {
    isLoading.value = true;
    try {
      final data = {
        "book": bookId,
        "title": title,
        "content": content,
        "status": "draft",
        "type": "description",
        "order_number": orderNumber,
      };

      print("Creating chapter with data: $data");

      await _userService.pb.collection('chapters').create(body: data);
      
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

class ChapterController extends GetxController {
  final isLoading = false.obs;
  final UserService _userService;
  
  ChapterController() : _userService = Get.find<UserService>();

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
      final result = await _userService.pb.collection('chapters').getFullList(
        filter: 'book = "$bookId" && type = "chapter"',
        sort: 'order_number',
      );
      return result.map((record) => record.data).toList();
    } catch (e) {
      print('Error fetching chapters: $e');
      return [];
    }
  }
} 
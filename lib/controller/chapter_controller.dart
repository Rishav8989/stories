import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

class ChapterController extends GetxController {
  late final UserService _userService;
  final isLoading = false.obs;
  final currentContent = ''.obs;
  final currentChapterId = ''.obs;
  final chapterTitle = ''.obs;
  final chapterStatus = ''.obs;
  final currentChapterOrder = 0.obs;
  UnsubscribeFunc? _chapterSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _userService = Get.find<UserService>();
  }

  @override
  void onClose() {
    _unsubscribeFromChapter();
    super.onClose();
  }

  void _unsubscribeFromChapter() {
    _chapterSubscription?.call();
    _chapterSubscription = null;
  }

  Future<void> _subscribeToChapter(String chapterId) async {
    // Unsubscribe from previous subscription if exists
    _unsubscribeFromChapter();

    // Subscribe to changes in the specific chapter
    _chapterSubscription = await _userService.pb.collection('chapters').subscribe(
      chapterId,
      (e) {
        if (e.action == 'update') {
          // Update local state with new data
          final record = e.record;
          if (record != null) {
            currentContent.value = record.data['content'] ?? '';
            chapterTitle.value = record.data['title'] ?? '';
            chapterStatus.value = record.data['status'] ?? 'draft';
            currentChapterOrder.value = record.data['order_number'] ?? 0;
          }
        }
      },
    );
  }

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
    required int orderNumber,
  }) async {
    if (!await isBookOwner(bookId)) {
      Get.snackbar('Error', 'Only the book author can add chapters', backgroundColor: Colors.red);
      return;
    }

    isLoading.value = true;
    try {
      await _userService.pb.collection('chapters').create(body: {
        'book': bookId,
        'title': title,
        'content': content,
        'type': 'content',
        'order_number': orderNumber,
        'status': 'draft',
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

  Future<bool> publishChapter(String chapterId) async {
    try {
      isLoading.value = true;

      // Get current chapter data
      final currentChapter = await _userService.pb.collection('chapters').getOne(chapterId);
      
      final data = {
        'title': currentChapter.data['title'],
        'content': currentChapter.data['content'],
        'status': 'published',
        'book': currentChapter.data['book'],
        'type': currentChapter.data['type'],
        'order_number': currentChapter.data['order_number'],
        'updated': DateTime.now().toIso8601String(),
        'published': DateTime.now().toIso8601String(),
      };

      await _userService.pb.collection('chapters').update(chapterId, body: data);
      
      // Update local state if this is the current chapter
      if (currentChapter.id == currentChapterId.value) {
        chapterStatus.value = 'published';
      }

      Get.snackbar(
        'Success',
        'Chapter published successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print('Error publishing chapter: $e');
      Get.snackbar(
        'Error',
        'Failed to publish chapter: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateChapter({
    required String chapterId,
    required String title,
    required String content,
    String? status,
  }) async {
    try {
      isLoading.value = true;

      // Get current chapter data to preserve other fields
      final currentChapter = await _userService.pb.collection('chapters').getOne(chapterId);
      
      final data = {
        'title': title,
        'content': content,
        'status': 'draft', // Always save as draft
        'book': currentChapter.data['book'],
        'type': currentChapter.data['type'],
        'order_number': currentChapter.data['order_number'],
        'updated': DateTime.now().toIso8601String(),
      };

      await _userService.pb.collection('chapters').update(chapterId, body: data);
      
      // Update local state if this is the current chapter
      if (currentChapter.id == currentChapterId.value) {
        currentContent.value = content;
        chapterTitle.value = title;
        chapterStatus.value = 'draft';
      }

      Get.snackbar(
        'Success',
        'Chapter saved as draft',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      print('Error updating chapter: $e');
      Get.snackbar(
        'Error',
        'Failed to update chapter: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return false;
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

  Future<Map<String, dynamic>?> getChapterContent(String chapterId) async {
    try {
      final record = await _userService.pb
          .collection('chapters')
          .getOne(chapterId);
      
      if (record.data.isEmpty) {
        throw Exception('Chapter content is empty');
      }
      
      final content = {
        'title': record.data['title'] ?? 'Untitled Chapter',
        'content': record.data['content'] ?? '',
        'status': record.data['status'] ?? 'draft',
        'order_number': record.data['order_number'] ?? 0,
      };
      
      currentContent.value = content['content'] ?? '';
      chapterTitle.value = content['title'] ?? '';
      chapterStatus.value = content['status'] ?? 'draft';
      currentChapterOrder.value = content['order_number'] ?? 0;
      currentChapterId.value = chapterId;

      // Subscribe to real-time updates for this chapter
      await _subscribeToChapter(chapterId);
      
      return content;
    } catch (e) {
      print("Error fetching chapter content: $e");
      if (e is ClientException) {
        if (e.statusCode == 404) {
          throw Exception('Chapter not found');
        } else if (e.statusCode == 401) {
          throw Exception('You do not have permission to view this chapter');
        }
      }
      throw Exception('Failed to load chapter content: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getPreviousChapter(String bookId, int currentOrder) async {
    try {
      final result = await _userService.pb.collection('chapters').getList(
        filter: 'book = "$bookId" && order_number < $currentOrder',
        sort: '-order_number',
        perPage: 1,
      );
      return result.items.isNotEmpty ? result.items.first.toJson() : null;
    } catch (e) {
      print('Error getting previous chapter: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getNextChapter(String bookId, int currentOrder) async {
    try {
      final result = await _userService.pb.collection('chapters').getList(
        filter: 'book = "$bookId" && order_number > $currentOrder',
        sort: 'order_number',
        perPage: 1,
      );
      return result.items.isNotEmpty ? result.items.first.toJson() : null;
    } catch (e) {
      print('Error getting next chapter: $e');
      return null;
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/bookDetails/book_description_logic.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/controller/chapter_controller.dart';
import 'package:stories/controller/bookDetails/chapter_management_logic.dart';
import 'package:stories/models/chapter_model.dart';

class BookDetailsController extends GetxController with ChapterManagementLogic {
  final UserService userService;
  final String bookId;
  final PocketBase pb;
  final Rx<BookModel?> book = Rx<BookModel?>(null);
  final RxList<ChapterModel> chapters = <ChapterModel>[].obs;
  final RxBool isLoading = false.obs;
  final hasDescription = false.obs;
  final Rx<ChapterModel?> description = Rx<ChapterModel?>(null);
  final Rx<String?> descriptionId = Rx<String?>(null);
  String? userId;
  String? errorMessage;

  BookDetailsController({
    required this.userService,
    required this.bookId,
    required this.pb,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeUserId();
    fetchBookDetails();
    fetchDescription();
    fetchChapters();
  }

  Future<void> _initializeUserId() async {
    userId = await userService.getUserId();
  }

  Future<void> fetchBookDetails() async {
    try {
      isLoading.value = true;
      final bookResult = await pb.collection('books').getOne(bookId);
      book.value = BookModel.fromJson(bookResult.toJson());
      await fetchDescription();
      await fetchChapters();
    } catch (e) {
      errorMessage = 'Failed to fetch book details: $e';
      Get.snackbar('Error', errorMessage!, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDescription() async {
    hasDescription.value = false;
    description.value = null;
    descriptionId.value = null;

    try {
      final result = await pb.collection('chapters').getFirstListItem(
        'book = "$bookId" && type = "description"',
      );
      description.value = ChapterModel.fromJson(result.toJson());
      hasDescription.value = true;
      descriptionId.value = result.id;
    } catch (e) {
      if (e is ClientException && e.statusCode == 404) {
        hasDescription.value = false;
      } else {
        print("Error fetching description: $e");
        Get.snackbar('Error', 'Failed to fetch description', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Future<void> fetchChapters() async {
    try {
      final result = await pb.collection('chapters').getList(
        filter: 'book = "$bookId" && type = "content"',
        sort: 'order_number',
      );
      chapters.value = result.items.map((item) => ChapterModel.fromJson(item.toJson())).toList();
    } catch (e) {
      print("Error fetching chapters: $e");
      Get.snackbar('Error', 'Failed to fetch chapters', backgroundColor: Colors.red);
    }
  }

  Future<int> getNextChapterOrderNumber() async {
    try {
      final result = await pb.collection('chapters').getList(
        filter: 'book = "$bookId" && type = "content"',
        sort: '-order_number',
        perPage: 1,
      );
      if (result.items.isEmpty) return 1;
      return (result.items.first.data['order_number'] as int) + 1;
    } catch (e) {
      print("Error getting next order number: $e");
      return 1;
    }
  }

  String getBookCoverThumbnailUrl() {
    if (book.value?.bookCover == null) return '';
    return '${pb.baseUrl}/api/files/books/${book.value!.id}/${book.value!.bookCover}?thumb=100x100';
  }

  Future<void> updateBook(String bookId, String title, String description) async {
    try {
      await pb.collection('books').update(bookId, body: {
        'title': title,
        'description': description,
      });
      await fetchBookDetails();
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<void> saveChapterOrder() async {
    try {
      for (var i = 0; i < chapters.length; i++) {
        await pb.collection('chapters').update(chapters[i].id, body: {
          'order_number': i + 1,
        });
      }
      await fetchChapters();
    } catch (e) {
      throw Exception('Failed to save chapter order: $e');
    }
  }

  void updateChapterOrder(List<ChapterModel> newOrder) {
    chapters.value = newOrder;
  }
}
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/discover_page_controller.dart';
import 'package:stories/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/utils/cached_image_manager.dart';

class BookDetailsController extends GetxController {
  final isLoading = true.obs;
  final Rx<Book?> book = Rx<Book?>(null);
  final hasDescription = false.obs;
  final Rx<String?> description = Rx<String?>(null);
  final Rx<String?> descriptionId = Rx<String?>(null);
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
    fetchDescription();
  }

  Future<void> _initializeUserId() async {
    userId = await _userService.getUserId();
  }

  Future<void> fetchBookDetails() async {
    try {
      final record = await _userService.pb
          .collection('books')
          .getOne(bookId, expand: 'author');

      book.value = Book.fromJson(record.data);
      isLoading.value = false;
    } catch (e) {
      errorMessage = 'Failed to load book details';
      isLoading.value = false;
    }
  }

  Future<void> fetchDescription() async {
    try {
      final descriptionRecord = await _userService.pb
          .collection('chapters')
          .getFirstListItem('book = "$bookId" && type = "description"');

      if (descriptionRecord != null) {
        hasDescription.value = true;
        description.value = descriptionRecord.data['content'];
        descriptionId.value = descriptionRecord.id;
      } else {
        hasDescription.value = false;
        description.value = null;
      }
    } catch (e) {
      hasDescription.value = false;
      description.value = null;
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
          content: const Text(
            'Are you sure you want to publish this book? Published books will be visible to all users.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Publish'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));
      await pb
          .collection('books')
          .update(bookId, body: {"status": "published"});

      // Find and refresh the DiscoverController if it exists
      final discoverController = Get.find<DiscoverController>();
      await discoverController.refreshBooks();

      // Navigate back and return true to trigger create page refresh
      Get.back(result: true);
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to publish book: $e'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBook() async {
    try {
      isLoading.value = true;
      await _userService.pb.collection('books').delete(bookId);
      Get.back(result: true); // Return true to indicate successful deletion
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete book',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addDescription(String content) async {
    try {
      isLoading.value = true;

      // First, check if a description already exists
      final existingDescriptions = await _userService.pb
          .collection('chapters')
          .getFullList(filter: 'book = "$bookId" && type = "description"');

      // If description already exists, show error
      if (existingDescriptions.isNotEmpty) {
        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Book already has a description. Please edit the existing description instead.',
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
        return;
      }

      // Create new description
      await _userService.pb
          .collection('chapters')
          .create(
            body: {
              "book": bookId,
              "title": "Description",
              "content": content,
              "status": "draft",
              "type": "description",
              "order_number": 0 as int, // Explicitly cast as integer
            },
          );

      await fetchBookDetails(); // Refresh book details
      await fetchDescription(); // Fetch the description
      Get.back(); // Close the dialog

      Get.snackbar(
        'Success',
        'Description added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to add description: $e'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editDescription(String content) async {
    try {
      isLoading.value = true;

      if (descriptionId.value == null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: const Text('No description found to edit.'),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
        return;
      }

      // Update existing description
      final data = {
        "book": bookId,
        "title": "Description",
        "content": content,
        "status": "draft",
        "type": "description",
        "order_number": 0,
      };

      await _userService.pb
          .collection('chapters')
          .update(descriptionId.value!, body: data);
      await fetchDescription(); // Refresh description
      Get.back(); // Close the dialog

      Get.snackbar(
        'Success',
        'Description updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update description: $e'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('OK')),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showEditDescriptionDialog() {
    final TextEditingController descriptionController = TextEditingController(
      text: description.value,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Description'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Enter book description...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (descriptionController.text.trim().isNotEmpty) {
                editDescription(descriptionController.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget getBookCoverImage({double? width, double? height}) {
    final String? imageUrl =
        book.value?.bookCover != null
            ? '${dotenv.get('POCKETBASE_URL')}/api/files/${book.value?.collectionId}/${book.value?.id}/${book.value?.bookCover}'
            : null;

    return CachedImageManager.getBookCover(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  Widget getAuthorProfileImage({double? width, double? height}) {
    // Since author is just an ID in the Book model, we need to handle this differently
    final authorData = book.value?.expand?['author'] as Map<String, dynamic>?;
    final String? imageUrl =
        authorData?['avatar'] != null
            ? '${dotenv.get('POCKETBASE_URL')}/api/files/_pb_users_auth_/${authorData?['id']}/${authorData?['avatar']}'
            : null;

    return CachedImageManager.getProfileImage(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

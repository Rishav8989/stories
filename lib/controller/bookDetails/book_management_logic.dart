import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/controller/discover_page_controller.dart';

extension BookManagementLogic on BookDetailsController {
  Future<void> publishBook() async {
    final currentBook = book.value;
    if (currentBook == null || currentBook.status != 'draft') return;

    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text('Publish Book'),
      content: const Text('Are you sure?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        TextButton(onPressed: () => Get.back(result: true), child: const Text('Publish')),
      ],
    ));

    if (confirm != true) return;

    try {
      await userService.pb.collection('books').update(bookId, body: {"status": "published"});
      await fetchBookDetails();

      final discoverController = Get.isRegistered<DiscoverController>()
          ? Get.find<DiscoverController>()
          : null;
      await discoverController?.refreshBooks();

      Get.back(result: true);
      Get.snackbar('Success', 'Book published!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error publishing: $e");
    }
  }

  Future<void> deleteBook() async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text('Delete Book'),
      content: const Text('Are you sure?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
        TextButton(onPressed: () => Get.back(result: true), child: const Text('Delete')),
      ],
    ));

    if (confirm != true) return;

    try {
      await userService.pb.collection('books').delete(bookId);

      final discoverController = Get.isRegistered<DiscoverController>()
          ? Get.find<DiscoverController>()
          : null;
      await discoverController?.refreshBooks();

      Get.back(result: true);
      Get.snackbar('Success', 'Book deleted!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error deleting: $e");
      Get.snackbar('Error', 'Failed to delete book', backgroundColor: Colors.red);
    }
  }
}
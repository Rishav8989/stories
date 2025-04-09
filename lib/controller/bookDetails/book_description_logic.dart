import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

extension BookDescriptionLogic on BookDetailsController {
  Future<void> fetchDescription() async {
    hasDescription.value = false;
    description.value = null;
    descriptionId.value = null;

    try {
      if (bookId.isEmpty) return;

      final descriptionRecord = await userService.pb
          .collection('chapters')
          .getFirstListItem('book = "$bookId" && type = "description"');

      hasDescription.value = true;
      description.value = descriptionRecord.data['content'];
      descriptionId.value = descriptionRecord.id;
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        hasDescription.value = false;
      }
    } catch (e) {
      print("Error fetching description: $e");
    }
  }

  Future<void> addDescription(String content) async {
    if (content.trim().isEmpty) {
      Get.snackbar('Error', 'Description cannot be empty.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      if (hasDescription.value) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: const Text('Book already has a description.'),
          actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
        ));
        return;
      }

      await userService.pb.collection('chapters').create(body: {
        "book": bookId,
        "title": "Description",
        "content": content.trim(),
        "status": "draft",
        "type": "description",
        "order_number": 0,
      });

      await fetchDescription();
      Get.back();
      Get.snackbar('Success', 'Description added!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error adding description: $e");
    }
  }

  Future<void> editDescription(String content) async {
    if (content.trim().isEmpty) {
      Get.snackbar('Error', 'Description cannot be empty.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      if (descriptionId.value == null) {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: const Text('No description found.'),
          actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
        ));
        return;
      }

      await userService.pb.collection('chapters').update(descriptionId.value!, body: {
        "content": content.trim(),
      });

      await fetchDescription();
      Get.back();
      Get.snackbar('Success', 'Description updated!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error editing description: $e");
    }
  }

  void showEditDescriptionDialog() {
    final controller = TextEditingController(text: description.value ?? '');

    Get.dialog(AlertDialog(
      title: Text(hasDescription.value ? 'Edit' : 'Add'),
      content: TextField(
        controller: controller,
        maxLines: 10,
        decoration: const InputDecoration(hintText: 'Enter description...'),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final newContent = controller.text.trim();
            if (newContent.isNotEmpty) {
              hasDescription.value ? editDescription(newContent) : addDescription(newContent);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }
}
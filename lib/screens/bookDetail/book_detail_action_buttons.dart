import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_description_logic.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

class BookDetailActionButtons extends StatelessWidget {
  final BookDetailsController controller;

  const BookDetailActionButtons({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Obx(() => controller.hasDescription.value
            ? const SizedBox.shrink()
            : Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final TextEditingController descriptionController =
                        TextEditingController();

                    Get.dialog(
                      AlertDialog(
                        title: const Text('Add Description'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: descriptionController,
                              maxLines: 10,
                              minLines: 3,
                              maxLength: 250,
                              decoration: const InputDecoration(
                                hintText: 'Enter book description...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              if (descriptionController.text
                                  .trim()
                                  .isNotEmpty) {
                                controller.addDescription(
                                    descriptionController.text.trim());
                                Get.back();
                              } else {
                                Get.snackbar(
                                  'Empty Description',
                                  'Please enter a description before saving.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.description),
                  label: const Text(
                    'ADD DESCRIPTION',
                    style: TextStyle(letterSpacing: 0.5),
                  ),
                ),
              )),
        Obx(() => controller.hasDescription.value
            ? const SizedBox.shrink()
            : const SizedBox(width: 16)),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Get.snackbar(
                  'Info', 'Add Chapter functionality not implemented yet.');
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'ADD CHAPTER',
              style: TextStyle(letterSpacing: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

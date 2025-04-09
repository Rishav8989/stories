import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_description_logic.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/screens/chapter/add_chapter_page.dart';

class BookDetailActionButtons extends StatelessWidget {
  final BookDetailsController controller;

  const BookDetailActionButtons({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout if width is less than 600 pixels
        final bool useColumnLayout = constraints.maxWidth < 600;

        Widget buildButton({
          required VoidCallback onPressed,
          required IconData icon,
          required String label,
        }) {
          return IntrinsicWidth(
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(
                label,
                style: const TextStyle(letterSpacing: 0.5),
              ),
            ),
          );
        }

        return useColumnLayout
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => controller.hasDescription.value
                      ? const SizedBox.shrink()
                      : buildButton(
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
                          icon: Icons.description,
                          label: 'Add Description',
                        )),
                  if (!controller.hasDescription.value) const SizedBox(height: 16),
                  buildButton(
                    onPressed: () {
                      Get.to(() => AddChapterPage(
                            bookId: controller.bookId,
                            nextOrderNumber: controller.nextChapterOrderNumber,
                          ));
                    },
                    icon: Icons.add_circle_outline,
                    label: 'Add Chapter',
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => controller.hasDescription.value
                      ? const SizedBox.shrink()
                      : buildButton(
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
                          icon: Icons.description,
                          label: 'Add Description',
                        )),
                  Obx(() => controller.hasDescription.value
                      ? const SizedBox.shrink()
                      : const SizedBox(width: 16)),
                  buildButton(
                    onPressed: () {
                      Get.to(() => AddChapterPage(
                            bookId: controller.bookId,
                            nextOrderNumber: controller.nextChapterOrderNumber,
                          ));
                    },
                    icon: Icons.add_circle_outline,
                    label: 'Add Chapter',
                  ),
                ],
              );
      },
    );
  }
}

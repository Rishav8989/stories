import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

class EditChapterPage extends StatelessWidget {
  final String chapterId;
  final String bookId;
  final String initialTitle;
  final String initialContent;

  const EditChapterPage({
    Key? key,
    required this.chapterId,
    required this.bookId,
    required this.initialTitle,
    required this.initialContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller with the correct bookId if not already initialized
    if (!Get.isRegistered<BookDetailsController>()) {
      Get.put(BookDetailsController(
        userService: Get.find(),
        pb: Get.find(),
        bookId: bookId,
      ));
    } else {
      final controller = Get.find<BookDetailsController>();
      if (controller.bookId != bookId) {
        // If bookId is different, replace the controller
        Get.replace(BookDetailsController(
          userService: Get.find(),
          pb: Get.find(),
          bookId: bookId,
        ));
      }
    }

    final controller = Get.find<BookDetailsController>();
    final titleController = TextEditingController(text: initialTitle);
    final contentController = TextEditingController(text: initialContent);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Chapter'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
                enabled: !controller.isLoading.value,
                decoration: const InputDecoration(
                  labelText: 'Chapter Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a chapter title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                enabled: !controller.isLoading.value,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Chapter Content',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter chapter content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            await controller.updateChapter(
                              chapterId: chapterId,
                              title: titleController.text.trim(),
                              content: contentController.text.trim(),
                            );
                          } catch (e) {
                            // Error is already handled in the controller
                          }
                        }
                      },
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          )),
        ),
      ),
    );
  }
} 
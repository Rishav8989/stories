import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/chapter_controller.dart';

class AddChapterPage extends StatelessWidget {
  final String bookId;
  final int nextOrderNumber;

  const AddChapterPage({
    Key? key,
    required this.bookId,
    required this.nextOrderNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChapterController());
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Chapter'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
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
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              controller.createChapter(
                                bookId: bookId,
                                title: titleController.text.trim(),
                                content: contentController.text.trim(),
                                orderNumber: nextOrderNumber,
                              );
                            }
                          },
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Add Chapter'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
} 
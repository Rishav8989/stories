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
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    controller.updateChapter(
                      chapterId: chapterId,
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
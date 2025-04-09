import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';

class EditBookPage extends StatelessWidget {
  final BookModel book;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  EditBookPage({Key? key, required this.book}) : super(key: key) {
    _titleController.text = book.title;
    _descriptionController.text = book.description;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookDetailsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await controller.updateBook(
                    book.id,
                    _titleController.text.trim(),
                    _descriptionController.text.trim(),
                  );
                  Get.back();
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to update book',
                    backgroundColor: colorScheme.error,
                    colorText: colorScheme.onError,
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Title',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Enter book title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      style: textTheme.bodyLarge,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter book description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
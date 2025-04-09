import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/utils/reading_time_calculator.dart';

class EditChapterPage extends StatefulWidget {
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
  State<EditChapterPage> createState() => _EditChapterPageState();
}

class _EditChapterPageState extends State<EditChapterPage> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController contentController;
  final RxInt wordCount = 0.obs;
  final RxInt lineCount = 0.obs;
  final RxDouble fontSize = 16.0.obs;
  final RxBool _hasUnsavedChanges = false.obs;
  late BookDetailsController bookDetailsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
    _updateCounts(widget.initialContent);
    
    // Initialize BookDetailsController with the correct bookId
    bookDetailsController = Get.put(
      BookDetailsController(
        userService: Get.find(),
        pb: Get.find(),
        bookId: widget.bookId,
      ),
      tag: 'edit_chapter_${widget.chapterId}',
      permanent: false,
    );

    // Add listeners for detecting changes
    titleController.addListener(() {
      _onContentChanged();
      _updateCounts(contentController.text);
    });
    contentController.addListener(() {
      _onContentChanged();
      _updateCounts(contentController.text);
    });
  }

  void _updateCounts(String text) {
    // Update word count (split by whitespace and filter empty strings)
    wordCount.value = text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    
    // Update line count
    lineCount.value = text.trim().split('\n').length;
  }

  void _onContentChanged() {
    _hasUnsavedChanges.value = true;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    Get.delete<BookDetailsController>(tag: 'edit_chapter_${widget.chapterId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        if (_hasUnsavedChanges.value) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('Do you want to save your changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      try {
                        await bookDetailsController.updateChapter(
                          chapterId: widget.chapterId,
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to save chapter: ${e.toString()}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.8),
                          colorText: Colors.white,
                          duration: const Duration(seconds: 5),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Chapter'),
          actions: [
            TextButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    await bookDetailsController.updateChapter(
                      chapterId: widget.chapterId,
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                    );
                    _hasUnsavedChanges.value = false;
                    Get.back(result: true);
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Failed to save chapter: ${e.toString()}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
        body: Obx(() => Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Chapter Title',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: titleController,
                    style: TextStyle(
                      fontSize: fontSize.value + 4,
                      color: textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter chapter title',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Word count: ${wordCount.value} | Lines: ${lineCount.value} | ${ReadingTimeCalculator.calculateReadingTime(contentController.text)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chapter Content',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: contentController,
                    style: TextStyle(
                      fontSize: fontSize.value,
                      color: textTheme.bodyLarge?.color,
                      height: 1.5,
                    ),
                    maxLines: null,
                    minLines: 15,
                    decoration: InputDecoration(
                      hintText: 'Enter chapter content',
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter content' : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
} 
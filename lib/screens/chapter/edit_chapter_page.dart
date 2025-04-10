import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/chapter_controller.dart';
import 'package:stories/utils/reading_time_calculator.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

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
  late ChapterController controller;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
    _updateCounts(widget.initialContent);
    
    // Initialize ChapterController and check permissions
    controller = Get.find<ChapterController>();
    _checkPermissions();

    // Add listeners for detecting changes
    titleController.addListener(() {
      _onContentChanged();
      _updateCounts(titleController.text);
    });
    contentController.addListener(() {
      _onContentChanged();
      _updateCounts(contentController.text);
    });
  }

  Future<void> _checkPermissions() async {
    final isAuthor = await controller.isBookOwner(widget.bookId);
    if (!isAuthor) {
      Get.back();
      Get.snackbar(
        'Access Denied',
        'Only the author can edit chapters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
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
                        await controller.updateChapter(
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
            Obx(() => TextButton(
              onPressed: controller.isLoading.value ? null : () async {
                if (formKey.currentState?.validate() ?? false) {
                  // Show saving dialog
                  Get.dialog(
                    WillPopScope(
                      onWillPop: () async => false, // Prevent closing with back button
                      child: Center(
                        child: Card(
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Saving chapter...',
                                  style: textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );

                  try {
                    final success = await controller.updateChapter(
                      chapterId: widget.chapterId,
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                    );

                    // Close the saving dialog
                    Get.back();

                    if (success) {
                      _hasUnsavedChanges.value = false;
                      
                      // Find and refresh BookDetailsController if it exists
                      try {
                        final bookController = Get.find<BookDetailsController>();
                        await bookController.fetchChapters();
                      } catch (e) {
                        print('BookDetailsController not found or refresh failed: $e');
                      }

                      // Return to previous screen with refresh signal and force navigation
                      Get.back(result: true);
                      Get.back();
                    }
                  } catch (e) {
                    // Close the saving dialog if still open
                    if (Get.isDialogOpen ?? false) {
                      Get.back();
                    }

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
              child: controller.isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save'),
            )),
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
                    maxLines: null,
                    style: TextStyle(
                      fontSize: fontSize.value,
                      color: textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter chapter content',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter content' : null,
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
} 
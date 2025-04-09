import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  final formKey = GlobalKey<FormState>();
  final RxInt wordCount = 0.obs;
  final RxInt lineCount = 0.obs;
  final RxBool isDarkMode = false.obs;
  final RxDouble fontSize = 16.0.obs;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
    _updateCounts(widget.initialContent);
    
    // Listen to content changes
    contentController.addListener(() {
      _updateCounts(contentController.text);
    });
  }

  void _updateCounts(String text) {
    // Update word count (split by whitespace and filter empty strings)
    wordCount.value = text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    
    // Update line count
    lineCount.value = text.trim().split('\n').length;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller with the correct bookId if not already initialized
    if (!Get.isRegistered<BookDetailsController>()) {
      Get.put(BookDetailsController(
        userService: Get.find(),
        pb: Get.find(),
        bookId: widget.bookId,
      ));
    } else {
      final controller = Get.find<BookDetailsController>();
      if (controller.bookId != widget.bookId) {
        // If bookId is different, replace the controller
        Get.replace(BookDetailsController(
          userService: Get.find(),
          pb: Get.find(),
          bookId: widget.bookId,
        ));
      }
    }

    final controller = Get.find<BookDetailsController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.book.value?.title ?? 'Loading...',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Text(
              'Edit Chapter',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        )),
        centerTitle: true,
        actions: [
          // Writing mode toggle
          Obx(() => IconButton(
            icon: Icon(isDarkMode.value ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => isDarkMode.value = !isDarkMode.value,
            tooltip: 'Toggle Writing Mode',
          )),
          // Font size adjustment
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Adjust Font Size'),
                  content: Obx(() => Slider(
                    value: fontSize.value,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: fontSize.value.toStringAsFixed(1),
                    onChanged: (value) => fontSize.value = value,
                  )),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Adjust Font Size',
          ),
        ],
      ),
      body: Obx(() => Container(
        color: isDarkMode.value 
          ? const Color(0xFF1A1A1A)  // Dark writing mode background
          : Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: titleController,
                  enabled: !controller.isLoading.value,
                  style: TextStyle(
                    color: isDarkMode.value ? Colors.white : null,
                    fontSize: fontSize.value,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Chapter Title',
                    border: const OutlineInputBorder(),
                    labelStyle: TextStyle(
                      color: isDarkMode.value ? Colors.white70 : null,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDarkMode.value ? Colors.white30 : Colors.grey,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a chapter title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Stats display
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_list_numbered, 
                        size: 16, 
                        color: (isDarkMode.value ? Colors.white60 : Theme.of(context).textTheme.bodySmall?.color)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lineCount.value} lines',
                        style: TextStyle(
                          color: isDarkMode.value ? Colors.white60 : null,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.text_fields,
                        size: 16,
                        color: (isDarkMode.value ? Colors.white60 : Theme.of(context).textTheme.bodySmall?.color)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${wordCount.value} words',
                        style: TextStyle(
                          color: isDarkMode.value ? Colors.white60 : null,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time,
                        size: 16,
                        color: (isDarkMode.value ? Colors.white60 : Theme.of(context).textTheme.bodySmall?.color)
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${(wordCount.value / 200).ceil()} min read',
                        style: TextStyle(
                          color: isDarkMode.value ? Colors.white60 : null,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: contentController,
                  enabled: !controller.isLoading.value,
                  maxLines: null,
                  minLines: 10,
                  style: TextStyle(
                    color: isDarkMode.value ? Colors.white : null,
                    fontSize: fontSize.value,
                    height: 1.5,  // Line height for better readability
                  ),
                  decoration: InputDecoration(
                    labelText: 'Chapter Content',
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(
                      color: isDarkMode.value ? Colors.white70 : null,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDarkMode.value ? Colors.white30 : Colors.grey,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter chapter content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: isDarkMode.value ? Colors.white24 : null,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                await controller.updateChapter(
                                  chapterId: widget.chapterId,
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
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
} 
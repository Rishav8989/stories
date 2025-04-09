import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/chapter_controller.dart';
import 'package:stories/screens/chapter/edit_chapter_page.dart';
import 'package:stories/utils/reading_time_calculator.dart';

class ChapterContentPage extends StatelessWidget {
  final String chapterId;
  final String bookId;
  final String chapterTitle;
  final String status;

  const ChapterContentPage({
    Key? key,
    required this.chapterId,
    required this.bookId,
    required this.chapterTitle,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final controller = Get.put(ChapterController());

    // Load initial content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getChapterContent(chapterId);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(chapterTitle),
        centerTitle: true,
        actions: [
          if (status == 'draft')
            IconButton(
              icon: const Icon(Icons.publish),
              onPressed: () => controller.publishChapter(chapterId),
              tooltip: 'Publish this chapter to make it visible to readers',
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit chapter title and content',
            onPressed: () async {
              try {
                final chapterContent = await controller.getChapterContent(chapterId);
                if (chapterContent != null) {
                  final result = await Get.to(() => EditChapterPage(
                    chapterId: chapterId,
                    bookId: bookId,
                    initialTitle: chapterContent['title'] ?? '',
                    initialContent: chapterContent['content'] ?? '',
                  ));
                  
                  // Refresh content if save was successful
                  if (result == true) {
                    await controller.getChapterContent(chapterId);
                  }
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to load chapter content: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final content = controller.currentContent.value;
        if (content.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                ReadingTimeCalculator.calculateReadingTime(content),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      final prevChapter = await controller.getPreviousChapter(bookId, controller.currentChapterOrder.value);
                      if (prevChapter != null) {
                        Get.off(() => ChapterContentPage(
                          chapterId: prevChapter['id'],
                          bookId: bookId,
                          chapterTitle: prevChapter['title'],
                          status: prevChapter['status'],
                        ));
                      }
                    },
                    tooltip: 'Previous Chapter',
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        content,
                        style: textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () async {
                      final nextChapter = await controller.getNextChapter(bookId, controller.currentChapterOrder.value);
                      if (nextChapter != null) {
                        Get.off(() => ChapterContentPage(
                          chapterId: nextChapter['id'],
                          bookId: bookId,
                          chapterTitle: nextChapter['title'],
                          status: nextChapter['status'],
                        ));
                      }
                    },
                    tooltip: 'Next Chapter',
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
} 
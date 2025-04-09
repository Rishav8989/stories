import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/chapter_controller.dart';
import 'package:stories/screens/chapter/edit_chapter_page.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(chapterTitle),
        centerTitle: true,
        actions: [
          if (status == 'draft')
            IconButton(
              icon: const Icon(Icons.publish),
              onPressed: () => controller.publishChapter(chapterId),
              tooltip: 'Publish Chapter',
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Chapter',
            onPressed: () async {
              final chapterContent = await controller.getChapterContent(chapterId);
              if (chapterContent != null) {
                Get.to(() => EditChapterPage(
                      chapterId: chapterId,
                      bookId: bookId,
                      initialTitle: chapterContent['title'] ?? '',
                      initialContent: chapterContent['content'] ?? '',
                    ));
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: controller.getChapterContent(chapterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading chapter: ${snapshot.error}',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            );
          }

          final content = snapshot.data?['content'] as String? ?? '';
          final paragraphs = content.split('\n\n');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    for (final paragraph in paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          paragraph,
                          style: textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 
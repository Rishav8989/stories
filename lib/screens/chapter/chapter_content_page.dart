import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/chapter_controller.dart';

class ChapterContentPage extends StatelessWidget {
  final String chapterId;
  final String? chapterTitle;
  final String? status;
  final String bookId;

  const ChapterContentPage({
    Key? key,
    required this.chapterId,
    required this.bookId,
    this.chapterTitle,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final controller = Get.find<ChapterController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(chapterTitle?.toUpperCase() ?? 'CHAPTER'),
        actions: [
          if (status == 'draft')
            IconButton(
              icon: const Icon(Icons.publish),
              tooltip: 'Publish Chapter',
              onPressed: () async {
                final confirm = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Publish Chapter'),
                    content: const Text('Are you sure you want to publish this chapter?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Publish'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  controller.publishChapter(chapterId);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Chapter',
            onPressed: () {
              // TODO: Implement edit chapter functionality
              Get.snackbar('Coming Soon', 'Chapter editing will be available soon!');
            },
          ),
        ],
      ),
      body: GetBuilder<ChapterController>(
        init: ChapterController(),
        builder: (controller) {
          return FutureBuilder<Map<String, dynamic>>(
            future: controller.getChapterContent(chapterId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading chapter content',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                );
              }

              final content = snapshot.data?['content'] as String?;
              if (content == null || content.isEmpty) {
                return Center(
                  child: Text(
                    'No content available',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Chapter title at the top
                        if (chapterTitle != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              chapterTitle!.toUpperCase(),
                              style: textTheme.headlineSmall?.copyWith(
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Chapter content
                        ...content.split('\n').map((paragraph) {
                          if (paragraph.trim().isEmpty) {
                            return const SizedBox(height: 16);
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              paragraph,
                              style: textTheme.bodyLarge?.copyWith(
                                letterSpacing: 0.5,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/screens/chapter/chapter_content_page.dart';

class BookDetailChapters extends StatelessWidget {
  final BookDetailsController controller;

  const BookDetailChapters({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() {
      if (controller.chapters.isEmpty) return const SizedBox.shrink();

      // Filter out description chapter (order_number 0) and sort by order_number
      final sortedChapters = controller.chapters
          .where((chapter) => chapter['order_number'] != 0)
          .toList()
        ..sort((a, b) => (a['order_number'] as int).compareTo(b['order_number'] as int));

      if (sortedChapters.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHAPTERS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedChapters.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chapter = sortedChapters[index];
                final orderNumber = chapter['order_number'] as int;
                return ListTile(
                  leading: Text(
                    '$orderNumber.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text(
                    chapter['title'] ?? 'Untitled Chapter',
                    style: textTheme.bodyMedium?.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.to(() => ChapterContentPage(
                          chapterId: chapter['id'],
                          chapterTitle: chapter['title'],
                        ));
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }
} 
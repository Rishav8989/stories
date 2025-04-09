import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/screens/chapter/chapter_content_page.dart';
import 'package:stories/screens/chapter/reorder_chapters_page.dart';

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
          .where((chapter) => chapter.orderNumber != 0)
          .toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

      if (sortedChapters.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHAPTERS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedChapters.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colorScheme.outline.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                final chapter = sortedChapters[index];
                final orderNumber = chapter.orderNumber;
                final status = chapter.status;
                return Container(
                  decoration: BoxDecoration(
                    color: status == 'draft' 
                        ? colorScheme.primary.withOpacity(0.05)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '$orderNumber',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      chapter.title,
                      style: textTheme.bodyMedium?.copyWith(
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status == 'draft')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Draft',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.to(() => ChapterContentPage(
                            chapterId: chapter.id,
                            bookId: controller.bookId,
                            chapterTitle: chapter.title,
                            status: status,
                          ));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
} 
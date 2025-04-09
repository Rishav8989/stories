import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

class ReorderChaptersPage extends StatelessWidget {
  final BookDetailsController controller;

  const ReorderChaptersPage({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Chapters'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              final sortedChapters = controller.chapters
                  .where((chapter) => chapter.orderNumber != 0)
                  .toList()
                ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
              controller.reorderChapters(sortedChapters);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Obx(() {
        final sortedChapters = controller.chapters
            .where((chapter) => chapter.orderNumber != 0)
            .toList()
          ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

        return ReorderableListView.builder(
          itemCount: sortedChapters.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = sortedChapters.removeAt(oldIndex);
            sortedChapters.insert(newIndex, item);
            controller.chapters.value = sortedChapters;
          },
          itemBuilder: (context, index) {
            final chapter = sortedChapters[index];
            final orderNumber = chapter.orderNumber;
            final status = chapter.status;

            return Container(
              key: Key(chapter.id),
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
                      Icons.drag_handle,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
} 
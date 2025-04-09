import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/chapter_model.dart';

class ReorderChaptersPage extends StatelessWidget {
  final BookDetailsController controller;

  const ReorderChaptersPage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth < 600 ? screenWidth - 32.0 : 600.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Chapters'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await controller.saveChapterOrder();
                Get.back();
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update chapter order',
                  backgroundColor: colorScheme.error,
                  colorText: colorScheme.onError,
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Obx(() {
            final chapters = controller.chapters
                .where((chapter) => chapter.orderNumber != 0)
                .toList()
              ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chapters.length,
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final chapter = chapters.removeAt(oldIndex);
                chapters.insert(newIndex, chapter);
                controller.updateChapterOrder(chapters);
              },
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return Card(
                  key: Key(chapter.id),
                  margin: const EdgeInsets.only(bottom: 8),
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
                          '${index + 1}',
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
                    subtitle: chapter.status == 'draft'
                        ? Text(
                            'Draft',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : null,
                    trailing: Icon(
                      Icons.drag_indicator,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
} 
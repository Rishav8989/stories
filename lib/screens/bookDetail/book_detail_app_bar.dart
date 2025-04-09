import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/controller/bookDetails/book_management_logic.dart';
import 'package:stories/screens/bookDetail/reorder_chapters_page.dart';
import 'package:stories/screens/bookDetail/edit_book_page.dart';

class BookDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final BookDetailsController controller;

  const BookDetailAppBar({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      title: Obx(() => Center(
          child: Text(controller.book.value?.title?.toUpperCase() ??
              'BOOK DETAILS'))),
      actions: [
        Obx(() {
          final book = controller.book.value;
          if (book == null) return const SizedBox.shrink();

          return Row(
            children: [
              if (book.status == 'draft')
                IconButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.publishBook,
                  icon: const Icon(Icons.publish),
                  tooltip: 'Publish',
                ),
              if (book.author == controller.userId)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Edit Book',
                            style: TextStyle(
                              letterSpacing: 0.5,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'reorder',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.reorder,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Reorder Chapters',
                            style: TextStyle(
                              letterSpacing: 0.5,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete Book',
                            style: TextStyle(
                              letterSpacing: 0.5,
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          titlePadding:
                              const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          contentPadding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          actionsPadding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          title: Text(
                            'Delete Book',
                            style: textTheme.titleLarge?.copyWith(
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: const Text(
                            'Are you sure you want to delete this book? This action cannot be undone.',
                            style: TextStyle(letterSpacing: 0.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(letterSpacing: 0.5),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await controller.deleteBook();
                          Get.back(
                              result:
                                  true); // Return to previous screen with deletion result
                        } catch (e) {
                          await Get.dialog(
                            AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Failed to delete book'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    } else if (value == 'edit') {
                      Get.to(() => EditBookPage(book: controller.book.value!));
                    } else if (value == 'reorder') {
                      Get.to(() => ReorderChaptersPage(controller: controller));
                    }
                  },
                ),
            ],
          );
        }),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_description_logic.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';

class BookDetailDescription extends StatelessWidget {
  final BookModel book;
  final BookDetailsController controller;

  const BookDetailDescription({
    Key? key,
    required this.book,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Obx(() {
      if (!controller.hasDescription.value) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPTION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onLongPress: book.author == controller.userId
                ? () => controller.showEditDescriptionDialog()
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (controller.description.value?.content ?? '') as String,
                    style: textTheme.bodyMedium?.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (book.author == controller.userId) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Long press to edit description',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

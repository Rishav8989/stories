import 'package:flutter/material.dart';
import 'package:stories/controller/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stories/screens/bookDetail/book_detail_action_buttons.dart';
import 'package:stories/screens/bookDetail/book_detail_description.dart';
import 'package:stories/screens/bookDetail/book_detail_info_card.dart';

class BookDetailContent extends StatelessWidget {
  final BookDetailsController controller;
  final Book book;

  const BookDetailContent({
    Key? key,
    required this.controller,
    required this.book,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (book.bookCover != null)
                Center(
                  child: Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      '${dotenv.get('POCKETBASE_URL')}/api/files/${book.collectionId}/${book.id}/${book.bookCover}?thumb=150x200',
                      height: 200,
                      width: 150,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          width: 150,
                          color: colorScheme.surfaceVariant,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: 150,
                          color: colorScheme.surfaceVariant,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48,
                              color: colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                book.title.toUpperCase(),
                style: textTheme.headlineMedium?.copyWith(
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              BookDetailInfoCard(book: book, controller: controller),
              const SizedBox(height: 24),
              BookDetailDescription(book: book, controller: controller),
              const SizedBox(height: 24),
              if (book.author == controller.userId)
                BookDetailActionButtons(controller: controller),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

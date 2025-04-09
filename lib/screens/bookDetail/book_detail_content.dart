import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX to use Obx
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';
// No longer need dotenv here for the image URL
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stories/screens/bookDetail/book_detail_action_buttons.dart';
import 'package:stories/screens/bookDetail/book_detail_description.dart';
import 'package:stories/screens/bookDetail/book_detail_info_card.dart';
import 'package:stories/screens/bookDetail/book_detail_chapters.dart';

class BookDetailContent extends StatelessWidget {
  // Make controller final as it shouldn't change after initialization
  final BookDetailsController controller;
  // Keep book final for initial data, but rely on controller.book for updates
  final Book book;

  const BookDetailContent({
    Key? key,
    required this.controller,
    required this.book, // Keep initial book for title/basic info if needed before controller loads fully
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Use Obx to reactively listen to changes in the controller's book value
    return Obx(() {
      // Get the latest book data from the controller
      // Use the initial book as a fallback if the controller's book is null (e.g., during initial load)
      final currentBook = controller.book.value ?? book;
      // Get the image URL from the controller
      final imageUrl = controller.bookCoverThumbnailUrl; // Use the new getter

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Use the imageUrl from the controller
                if (imageUrl != null)
                  Center(
                    child: Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // Use the imageUrl obtained from the controller
                      child: Image.network(
                        imageUrl, // Use the controller's URL
                        height: 200,
                        width: 150,
                        fit: BoxFit.cover,
                        // Keep loading and error builders as they handle UI presentation
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: 150,
                            color: colorScheme.surfaceVariant.withOpacity(0.5), // Slightly transparent
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2.0, // Make indicator slimmer
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          // Log the error for debugging
                          print("Error loading image $imageUrl: $error");
                          return Container(
                            height: 200,
                            width: 150,
                            color: colorScheme.surfaceVariant.withOpacity(0.5),
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined, // Use outlined version
                                size: 48,
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.6), // Adjust opacity
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                 else // Optional: Show a placeholder if imageUrl is null (e.g., book has no cover)
                  Center(
                      child: Card(
                           elevation: 4,
                           clipBehavior: Clip.antiAlias,
                           shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8),
                        ),
                          child: Container(
                              height: 200,
                              width: 150,
                              color: colorScheme.surfaceVariant.withOpacity(0.5),
                              child: Center(
                                  child: Icon(
                                  Icons.book_outlined, // Placeholder icon
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                                 ),
                               ),
                         ),
                      ),
                   ),

                const SizedBox(height: 24),
                // Use currentBook from controller for reactive updates
                Text(
                  currentBook.title.toUpperCase(),
                  style: textTheme.headlineMedium?.copyWith(
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Pass the reactive book value to child widgets if they need it
                BookDetailInfoCard(book: currentBook, controller: controller),
                const SizedBox(height: 24),
                BookDetailDescription(book: currentBook, controller: controller),
                const SizedBox(height: 24),
                BookDetailChapters(controller: controller),
                const SizedBox(height: 24),
                // Check author against controller's userId and use currentBook
                if (currentBook.author == controller.userId)
                  BookDetailActionButtons(controller: controller),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }); // End Obx
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:stories/controller/book_details_page_controller.dart';
import 'package:intl/intl.dart';

class BookDetailsPage extends GetView<BookDetailsController> {
  final String bookId;

  const BookDetailsPage({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookDetailsController>(
      init: BookDetailsController(bookId: bookId),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Obx(() => Text(controller.book.value?.title ?? 'Book Details')),
            actions: [
              Obx(() {
                final book = controller.book.value;
                if (book != null && book.status == 'draft') {  // Only show for draft status
                  return TextButton.icon(
                    onPressed: controller.isLoading.value 
                      ? null 
                      : controller.publishBook,
                    icon: const Icon(
                      Icons.publish,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Publish',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(child: Text(controller.errorMessage!));
            }

            final book = controller.book.value;
            if (book == null) return const Center(child: Text('Book not found'));

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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                '${dotenv.get('POCKETBASE_URL')}/api/files/${book.collectionId}/${book.id}/${book.bookCover}?thumb=150x200',
                                height: 200,
                                width: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    width: 150,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 48),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Status', book.status.capitalize!),
                              const SizedBox(height: 16),
                              _buildInfoRow('Type', book.bookType),
                              const SizedBox(height: 16),
                              _buildInfoRow('Genres', book.genre.join(", ")),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'Last updated',
                                DateFormat.yMMMd().format(book.updated),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'Source',
                                book.isOriginal
                                    ? 'Original Work'
                                    : 'Based on: ${book.parentBook ?? "Unknown"}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
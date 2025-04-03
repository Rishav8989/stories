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
                if (book != null && book.status == 'draft') {
                  return IconButton(
                    onPressed: controller.isLoading.value ? null : controller.publishBook,
                    icon: const Icon(Icons.publish),
                    tooltip: 'Publish',
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
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
                        book.title.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('STATUS', book.status.toUpperCase()),
                              const SizedBox(height: 16),
                              _buildInfoRow('TYPE', book.bookType.toUpperCase()),
                              const SizedBox(height: 16),
                              _buildInfoRow('GENRES', book.genre.join(", ").toUpperCase()),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'LAST UPDATED',
                                DateFormat.yMMMd().format(book.updated).toUpperCase(),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'SOURCE',
                                (book.isOriginal
                                    ? 'Original Work'
                                    : 'Based on: ${book.parentBook ?? "Unknown"}').toUpperCase(),
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
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:stories/controller/book_details_page_controller.dart';
import 'package:intl/intl.dart';
import 'package:stories/utils/user_service.dart';

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
            title: Obx(() => Center(child: Text(controller.book.value?.title?.toUpperCase() ?? 'BOOK DETAILS'))),
            actions: [
              Obx(() {
                final book = controller.book.value;
                if (book == null) return const SizedBox.shrink();
                
                return Row(
                  children: [
                    if (book.status == 'draft')
                      IconButton(
                        onPressed: controller.isLoading.value ? null : controller.publishBook,
                        icon: const Icon(Icons.publish),
                        tooltip: 'Publish',
                        style: IconButton.styleFrom(
                          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                      ),
                    if (book.author == controller.userId)  // Show menu only for book owner
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        offset: const Offset(0, 40),  // Move menu slightly down from app bar
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'delete',
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    letterSpacing: 0.5,
                                    color: Theme.of(context).colorScheme.error,
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
                                titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                                contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                                title: const Text(
                                  'Delete Book',
                                  style: TextStyle(
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
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
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
                                Get.back(result: true); // Return to previous screen with deletion result
                              } catch (e) {
                                // Show error in a dialog instead of snackbar
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
                          }
                        },
                      ),
                  ],
                );
              }),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Text(
                  controller.errorMessage!.toUpperCase(),
                  style: const TextStyle(letterSpacing: 0.5),
                ),
              );
            }

            final book = controller.book.value;
            if (book == null) {
              return const Center(
                child: Text(
                  'BOOK NOT FOUND',
                  style: TextStyle(letterSpacing: 0.5),
                ),
              );
            }

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
                      const SizedBox(height: 24),
                      if (book.author == controller.userId) // Only show buttons for the author
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Will implement description handling
                                },
                                icon: const Icon(Icons.description),
                                label: const Text(
                                  'ADD DESCRIPTION',
                                  style: TextStyle(letterSpacing: 0.5),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Will implement chapter handling
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text(
                                  'ADD CHAPTER',
                                  style: TextStyle(letterSpacing: 0.5),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
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
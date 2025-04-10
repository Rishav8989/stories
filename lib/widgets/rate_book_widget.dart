import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/rating_controller.dart';

class RateBookWidget extends StatelessWidget {
  final RatingController controller;

  const RateBookWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate This Book',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              final userRating = controller.userRating.value;
              if (userRating != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Rating',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < userRating.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                        const SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () => _showRatingDialog(
                            context,
                            initialRating: userRating.rating,
                            initialComment: userRating.reviewComment,
                          ),
                          icon: const Icon(Icons.edit, size: 20),
                          label: const Text('Edit'),
                        ),
                        TextButton.icon(
                          onPressed: () => _showDeleteConfirmation(context),
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('Remove'),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    if (userRating.reviewComment != null &&
                        userRating.reviewComment!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Your Review:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(userRating.reviewComment!),
                    ],
                  ],
                );
              } else {
                return Column(
                  children: [
                    const Text('Share your thoughts by rating this book'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return InkWell(
                          onTap: () => _showRatingDialog(context, initialRating: index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _showRatingDialog(
    BuildContext context, {
    required int initialRating,
    String? initialComment,
  }) async {
    int selectedRating = initialRating;
    final commentController = TextEditingController(text: initialComment);

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate ${selectedRating.toString()} Stars'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return InkWell(
                    onTap: () => setState(() => selectedRating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add a comment (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.rateBook(selectedRating, comment: commentController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Rating'),
        content: const Text('Are you sure you want to remove your rating?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteRating();
              Navigator.of(context).pop();
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
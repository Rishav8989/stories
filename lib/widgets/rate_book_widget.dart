import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/rating_controller.dart';

class RateBookWidget extends StatelessWidget {
  final RatingController controller;
  final showActions = false.obs;

  RateBookWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final userRating = controller.userRating.value;
              if (userRating != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Rating',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onLongPress: () => showActions.value = !showActions.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < userRating.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }),
                          ),
                          if (userRating.reviewComment != null &&
                              userRating.reviewComment!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              userRating.reviewComment!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                          Obx(() => showActions.value
                              ? Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            showActions.value = false;
                                            _showRatingDialog(
                                              context,
                                              userRating.rating,
                                              userRating.reviewComment,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: Colors.blue,
                                          ),
                                          label: Text(
                                            'Edit',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        TextButton.icon(
                                          onPressed: () {
                                            showActions.value = false;
                                            _showDeleteConfirmation(context);
                                          },
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          label: Text(
                                            'Remove',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Long press to edit or remove',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white38,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate This Book',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(5, (index) {
                        return InkWell(
                          onTap: () => _showRatingDialog(context, index + 1, null),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.star_border,
                              color: Colors.amber,
                              size: 24,
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
    BuildContext context,
    int initialRating,
    String? initialComment,
  ) async {
    int rating = initialRating;
    final commentController = TextEditingController(text: initialComment);

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Rate ${rating.toString()} Stars'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return InkWell(
                    onTap: () => setState(() => rating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        index < rating ? Icons.star : Icons.star_border,
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
              onPressed: () async {
                await controller.rateBook(rating, comment: commentController.text);
                Navigator.of(context).pop();
                Get.back(result: true);
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
            onPressed: () async {
              await controller.deleteRating();
              Navigator.of(context).pop();
              Get.back(result: true);
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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/rating_controller.dart';
import 'package:stories/models/rating_model.dart';

class BookRatingsPage extends StatelessWidget {
  final RatingController controller;
  final RxString sortBy = 'newest'.obs;

  BookRatingsPage({
    Key? key,
    required this.controller,
  }) : super(key: key);

  List<RatingModel> _getSortedRatings() {
    final ratings = List<RatingModel>.from(controller.ratings);
    switch (sortBy.value) {
      case 'newest':
        ratings.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'oldest':
        ratings.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case 'best':
        ratings.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'worst':
        ratings.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return ratings;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: () async {
        Get.back(result: true); // Return true to refresh the parent widget
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Ratings'),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.ratings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ratings yet',
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to rate this book!',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedRatings = _getSortedRatings();

          return Center(
            child: SizedBox(
              width: 600,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sort,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sort',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onSelected: (value) {
                            sortBy.value = value;
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'newest',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: sortBy.value == 'newest' ? colorScheme.primary : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Newest First'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'oldest',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: sortBy.value == 'oldest' ? colorScheme.primary : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Oldest First'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'best',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: sortBy.value == 'best' ? colorScheme.primary : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Best Ratings'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'worst',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star_border,
                                    color: sortBy.value == 'worst' ? colorScheme.primary : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Worst Ratings'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedRatings.length,
                      itemBuilder: (context, index) {
                        final rating = sortedRatings[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ...List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < rating.rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Rated ${rating.rating} stars',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (rating.reviewComment != null && rating.reviewComment!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    rating.reviewComment!,
                                    style: textTheme.bodyLarge,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(rating.updatedAt),
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stories/screens/book_detail_page.dart';
import 'package:stories/utils/cached_image_manager.dart';

class BookWidget extends StatelessWidget {
  final String title;
  final String coverUrl;
  final String pbUrl;
  final String bookId;
  final String collectionId;
  final VoidCallback? onTap;
  final String? thumbSize; // Add thumbSize parameter

  const BookWidget({
    Key? key,
    required this.title,
    required this.coverUrl,
    required this.pbUrl,
    required this.bookId,
    required this.collectionId,
    this.onTap,
    this.thumbSize, // Add to constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String fullImageUrl = coverUrl.isNotEmpty
        ? '$pbUrl/api/files/$collectionId/$bookId/$coverUrl${thumbSize != null ? '?thumb=$thumbSize' : ''}'
        : '';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedImageManager.getBookCover(
                fullImageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Update the grid delegate for more compact mobile layout
SliverGridDelegateWithFixedCrossAxisCount getResponsiveGridDelegate(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;
  
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: isMobile ? 3 : (screenWidth / 200).floor(),
    childAspectRatio: isMobile ? 0.5 : 0.6, // More compact for mobile
    crossAxisSpacing: isMobile ? 2 : 16,
    mainAxisSpacing: isMobile ? 4 : 24,
  );
}
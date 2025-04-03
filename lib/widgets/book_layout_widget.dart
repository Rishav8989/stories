import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:stories/screens/book_detail_page.dart';

class BookWidget extends StatelessWidget {
  final String title;
  final String coverUrl;
  final String pbUrl;
  final String bookId;
  final String collectionId;
  final VoidCallback? onTap;
  final String thumbSize;  // Add this parameter

  const BookWidget({
    Key? key,
    required this.title,
    required this.coverUrl,
    required this.pbUrl,
    required this.bookId,
    required this.collectionId,
    this.onTap,
    this.thumbSize = '150x200',  // Add default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Calculate dimensions maintaining 3:4 aspect ratio with reduced padding for mobile
    final coverWidth = isMobile 
        ? (screenWidth - 32) / 3 // Reduced padding for mobile
        : 150.0;
    final coverHeight = coverWidth * 1.33;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 4.0 : 8.0), // Reduced padding for mobile
      child: GestureDetector(
        onTap: () => Get.to(() => BookDetailsPage(bookId: bookId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Add this to prevent expansion
          children: [
            SizedBox(
              width: coverWidth,
              height: coverHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMobile ? 2 : 4),
                child: coverUrl.isNotEmpty
                    ? Image.network(
                        '$pbUrl/api/files/$collectionId/$bookId/$coverUrl?thumb=$thumbSize',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.broken_image, 
                                size: isMobile ? 20 : 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(Icons.image, 
                            size: isMobile ? 20 : 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: isMobile ? 4 : 8), // Reduced spacing for mobile
            SizedBox(
              height: isMobile ? 32 : 44,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 10 : 13,
                  height: 1.2,
                ),
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
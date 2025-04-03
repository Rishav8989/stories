import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      // Fetch PocketBase URL from environment variables
      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));

      // Fetch books from the 'books' collection
      final resultList = await pb.collection('books').getList(
        page: 1,
        perPage: 50,
          filter: 'status = "published"',

      );

      setState(() {
        _books.clear();
        for (var item in resultList.items) {
          _books.add(item.toJson());
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load books. Please try again.';
      });
      debugPrint('Error fetching books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Enforce a minimum width of 200 pixels for the entire page
        final minWidth = 200.0;
        final screenWidth = constraints.maxWidth;

        if (screenWidth < minWidth) {
          // If the screen width is less than the minimum width, center the content
          return Center(
            child: SizedBox(
              width: minWidth,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Discover Books'),
                ),
                body: _buildBody(),
              ),
            ),
          );
        }

        // Otherwise, display the Scaffold normally
        return Scaffold(
          appBar: AppBar(
            title: const Text('Discover Books'),
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Books',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Reduced spacing
          Expanded(
            child: _books.isEmpty
                ? const Center(child: Text('No books found'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate the number of columns based on screen width
                      final screenWidth = constraints.maxWidth;
                      const itemWidth = 200.0; // Desired width for each book item
                      final crossAxisCount = (screenWidth / itemWidth).floor();

                      return GridView.builder(
                        physics: const ClampingScrollPhysics(), // Prevent overscroll
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                          childAspectRatio: 0.75, // Adjusted aspect ratio
                          crossAxisSpacing: 4, // Further reduced spacing
                          mainAxisSpacing: 4, // Further reduced spacing
                        ),
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return BookWidget(
                            title: book['title'] ?? 'Unknown Title',
                            coverUrl: book['book_cover'] ?? '',
                            pbUrl: dotenv.get('POCKETBASE_URL'),
                            bookId: book['id'],
                            collectionId: book['collectionId'],
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class BookWidget extends StatelessWidget {
  final String title;
  final String coverUrl;
  final String pbUrl;
  final String bookId;
  final String collectionId;

  const BookWidget({
    Key? key,
    required this.title,
    required this.coverUrl,
    required this.pbUrl,
    required this.bookId,
    required this.collectionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to book details page
        // Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsPage(bookId: bookId)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fixed height for the image container
          SizedBox(
            width: 150, // Fixed width
            height: 200, // Fixed height
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: coverUrl.isNotEmpty
                  ? Image.network(
                      '$pbUrl/api/files/$collectionId/$bookId/$coverUrl?thumb=0x200',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.book, size: 40)),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.book, size: 40)),
                    ),
            ),
          ),
          const SizedBox(height: 4), // Further reduced spacing
          SizedBox(
            height: 40, // Clamp text height
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14, // Reduced font size
              ),
            ),
          ),
        ],
      ),
    );
  }
}
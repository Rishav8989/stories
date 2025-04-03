import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/widgets/book_layout_widget.dart';

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
    if (!mounted) return;

    try {
      // Fetch PocketBase URL from environment variables
      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));

      // Fetch books from the 'books' collection
      final resultList = await pb.collection('books').getList(
        page: 1,
        perPage: 50,
        filter: 'status = "published"',
      );

      if (!mounted) return;

      setState(() {
        _books.clear();
        for (var item in resultList.items) {
          _books.add(item.toJson());
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load books. Please try again.';
      });
      debugPrint('Error fetching books: $e');
    }
  }

  // Add refresh functionality
  Future<void> _refreshBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _fetchBooks();
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
                body: _buildBody(),
              ),
            ),
          );
        }

        // Otherwise, display the Scaffold normally
        return Scaffold(
          appBar: AppBar(
            title: Center(child: const Text('Discover Books')),
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          const SizedBox(height: 8),
          Expanded(
            child: _books.isEmpty
                ? const Center(child: Text('No books found'))
                : RefreshIndicator(
                    onRefresh: _refreshBooks,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate items per row based on screen width
                        final screenWidth = constraints.maxWidth;
                        int crossAxisCount;
                        double itemWidth;
                        double aspectRatio;
                        
                        if (screenWidth < 600) { // Mobile screen
                          crossAxisCount = 2;
                          itemWidth = (screenWidth - 24) / 2; // Account for padding
                          aspectRatio = 0.7; // Taller books for mobile
                        } else {
                          itemWidth = 200.0;
                          crossAxisCount = (screenWidth / itemWidth).floor();
                          aspectRatio = 0.6;
                        }

                        return GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate: getResponsiveGridDelegate(context),
                          itemCount: _books.length,
                          itemBuilder: (context, index) {
                            final book = _books[index];
                            return BookWidget(
                              title: book['title'] ?? 'Unknown Title',
                              coverUrl: book['book_cover'] ?? '',
                              pbUrl: dotenv.get('POCKETBASE_URL'),
                              bookId: book['id'],
                              collectionId: book['collectionId'],
                              onTap: () {
                                // Navigate to book details
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
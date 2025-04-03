// lib/pages/create_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:stories/utils/user_service.dart'; // Import UserService
import 'package:pocketbase/pocketbase.dart'; // Import PocketBase
import 'package:stories/utils/create_new_book.dart'; // Import CreateNewBookPage

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final List<Map<String, dynamic>> _userBooks = [];
  bool _isLoading = true;
  String? _errorMessage;

  final UserService _userService = UserService(PocketBase(dotenv.get('POCKETBASE_URL')));

  @override
  void initState() {
    super.initState();
    _fetchUserBooks();
  }

  Future<void> _fetchUserBooks() async {
    try {
      // Get the logged-in user's ID
      final userId = await _userService.getUserId();

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in.';
        });
        return;
      }

      // Fetch books authored by the logged-in user
      final resultList = await _userService.pb.collection('books').getList(
            page: 1,
            perPage: 50,
            filter: 'author = "$userId"', // Filter books by the logged-in user's ID
          );

      setState(() {
        _userBooks.clear();
        for (var item in resultList.items) {
          _userBooks.add(item.toJson());
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load books. Please try again.';
      });
      debugPrint('Error fetching user books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Enforce a minimum width of 200 pixels for the entire page
          final minWidth = 200.0;
          final screenWidth = constraints.maxWidth;

          if (screenWidth < minWidth) {
            // If the screen width is less than the minimum width, center the content
            return Center(
              child: SizedBox(
                width: minWidth,
                child: _buildContent(),
              ),
            );
          }

          // Otherwise, display the content normally
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _userBooks.isEmpty
                      ? const Center(child: Text('No books found'))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildUserBooksGrid(),
                        ),
        ),
        // Create Book button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => const CreateNewBookPage());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('Create Book'),
          ),
        ),
      ],
    );
  }

  Widget _buildUserBooksGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        int crossAxisCount;
        double itemWidth;
        double aspectRatio;
        
        if (screenWidth < 600) { // Mobile layout
          crossAxisCount = 2;
          itemWidth = (screenWidth - 24) / 2;
          aspectRatio = 0.7;
        } else { // Tablet/Desktop layout
          itemWidth = 150.0;
          crossAxisCount = (screenWidth / itemWidth).floor();
          aspectRatio = 0.75;
        }

        return GridView.builder(
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _userBooks.length,
          itemBuilder: (context, index) {
            final book = _userBooks[index];
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
          const SizedBox(height: 4), // Reduced spacing
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
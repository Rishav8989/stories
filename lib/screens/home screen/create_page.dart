// lib/pages/create_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:stories/screens/bookDetail/book_detail_page.dart';
import 'package:stories/utils/user_service.dart'; // Import UserService
import 'package:pocketbase/pocketbase.dart'; // Import PocketBase
import 'package:stories/utils/create_new_book.dart'; // Import CreateNewBookPage
import 'package:stories/widgets/book_layout_widget.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserBooks() async {
    if (!mounted) return;

    try {
      // Get the logged-in user's ID
      final userId = await _userService.getUserId();

      if (!mounted) return;

      if (userId == null) {
        _safeSetState(() {
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

      if (!mounted) return;

      _safeSetState(() {
        _userBooks.clear();
        for (var item in resultList.items) {
          _userBooks.add(item.toJson());
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      _safeSetState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load books. Please try again.';
      });
      debugPrint('Error fetching user books: $e');
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final minWidth = 200.0;
          final screenWidth = constraints.maxWidth;

          if (screenWidth < minWidth) {
            return Center(
              child: SizedBox(
                width: minWidth,
                child: _buildContent(),
              ),
            );
          }
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          pinned: false,
          snap: true,
          centerTitle: true,
          title: Text('My Books'),
          expandedHeight: 50.0,
        ),
        SliverFillRemaining(
          hasScrollBody: true,
          child: Column(
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
                  onPressed: () async {
                    final result = await Get.to(() => const CreateNewBookPage());
                    if (result == true) {
                      // Refresh the book list when returning from create page
                      _fetchUserBooks();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Create Book'),
                ),
              ),
            ],
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
          gridDelegate: getResponsiveGridDelegate(context),
          itemCount: _userBooks.length,
          itemBuilder: (context, index) {
            final book = _userBooks[index];
            return BookWidget(
              title: book['title'] ?? 'Unknown Title',
              coverUrl: book['book_cover'] ?? '',
              pbUrl: dotenv.get('POCKETBASE_URL'),
              bookId: book['id'],
              collectionId: book['collectionId'],
              onTap: () async {
                final result = await Get.to(() => BookDetailsPage(bookId: book['id']));
                // Refresh the books list if a book was deleted
                if (result == true) {
                  setState(() {
                    _userBooks.removeWhere((b) => b['id'] == book['id']);
                  });
                  await _fetchUserBooks(); // Refresh the full list from server
                }
              },
            );
          },
        );
      },
    );
  }
}
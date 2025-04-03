import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/widgets/book_layout_widget.dart';
import 'package:stories/utils/user_service.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final List<Map<String, dynamic>> _books = [];
  final List<Map<String, dynamic>> _userBooks = [];
  bool _isLoading = true;
  String? _errorMessage;
  final UserService _userService = UserService(PocketBase(dotenv.get('POCKETBASE_URL')));

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([
      _fetchBooks(),
      _fetchUserBooks(),
    ]);
  }

  Future<void> _fetchBooks() async {
    if (!mounted) return;

    try {
      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));
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

  Future<void> _fetchUserBooks() async {
    if (!mounted) return;

    try {
      final userId = await _userService.getUserId();
      
      if (userId != null) {
        final resultList = await _userService.pb.collection('books').getList(
          page: 1,
          perPage: 50,
          filter: 'author = "$userId" && status = "published"',
        );

        if (!mounted) return;

        setState(() {
          _userBooks.clear();
          for (var item in resultList.items) {
            _userBooks.add(item.toJson());
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching user books: $e');
    }
  }

  Future<void> _refreshBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _fetchInitialData();
  }

  Widget _buildBookRow(List<Map<String, dynamic>> books) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 160,
              child: BookWidget(
                title: book['title'] ?? 'Unknown Title',
                coverUrl: book['book_cover'] ?? '',
                pbUrl: dotenv.get('POCKETBASE_URL'),
                bookId: book['id'],
                collectionId: book['collectionId'],
                onTap: () {
                  // Navigate to book details
                },
              ),
            ),
          );
        },
      ),
    );
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
        final minWidth = 200.0;
        final screenWidth = constraints.maxWidth;

        if (screenWidth < minWidth) {
          return Center(
            child: SizedBox(
              width: minWidth,
              child: Scaffold(
                body: _buildBody(),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('Discover Books')),
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _refreshBooks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userBooks.isNotEmpty) ...[
                const Text(
                  'Your Published Books',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBookRow(_userBooks),
                const SizedBox(height: 32),
              ],
              const Text(
                'Trending Books',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _books.isEmpty
                  ? const Center(child: Text('No books found'))
                  : _buildBookRow(_books),
            ],
          ),
        ),
      ),
    );
  }
}
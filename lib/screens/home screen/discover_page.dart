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

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));
      
      final resultList = await pb.collection('books').getList(
        page: 1,
        perPage: 50,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Books'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            Expanded(
              child: _books.isEmpty
                  ? const Center(child: Text('No books found'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        return BookWidget(
                          title: book['title'] ?? 'Unknown Title',
                          coverUrl: book['book_cover'] ?? '',
                          pbUrl: 'http://127.0.0.1:8090',
                          bookId: book['id'],
                          collectionId: book['collectionId'],
                        );
                      },
                    ),
            ),
          ],
        ),
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
          Container(
            width: 200,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: coverUrl.isNotEmpty
                  ? Image.network(
                      '$pbUrl/api/files/$collectionId/$bookId/$coverUrl?thumb=0x200',
                      fit: BoxFit.cover,
                      width: 200,
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
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stories/controller/discover_page_controller.dart';
import 'package:stories/screens/book_detail_page.dart';
import 'package:stories/widgets/book_layout_widget.dart';

class DiscoverPage extends GetView<DiscoverController> {
  const DiscoverPage({Key? key}) : super(key: key);

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
                  Get.to(() => BookDetailsPage(bookId: book['id']));
                },
                thumbSize: '200x300', // Add thumbnail size parameter
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage != null) {
        return Center(child: Text(controller.errorMessage!));
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final minWidth = 200.0;
          final screenWidth = constraints.maxWidth;

          if (screenWidth < minWidth) {
            return Center(
              child: SizedBox(
                width: minWidth,
                child: _buildScaffold(),
              ),
            );
          }
          return _buildScaffold();
        },
      );
    });
  }

  Widget _buildScaffold() {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.refreshBooks,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              expandedHeight: 50.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Discover Books'),
                centerTitle: true,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (controller.userBooks.isNotEmpty) ...[
                    const Text(
                      'Your Published Books',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBookRow(controller.userBooks),
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
                  controller.books.isEmpty
                      ? const Center(child: Text('No books found'))
                      : _buildBookRow(controller.books),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
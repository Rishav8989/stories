import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/discover_page_controller.dart';
import 'package:stories/screens/bookDetail/book_detail_page.dart';
import 'package:stories/widgets/book_layout_widget.dart';

class DiscoverPage extends GetView<DiscoverController> {
  const DiscoverPage({Key? key}) : super(key: key);

  Widget _buildBookRow(String title, List<RecordModel> books) {
    if (books.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 160,
                  child: BookWidget(
                    title: book.data['title'] ?? 'Unknown Title',
                    coverUrl: book.data['book_cover'] ?? '',
                    pbUrl: dotenv.get('POCKETBASE_URL'),
                    bookId: book.id,
                    collectionId: book.collectionId,
                    thumbSize: '200x300',
                    onTap: () {
                      if (book.id != null) {
                        Get.to(() => BookDetailsPage(bookId: book.id));
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshBooks,
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

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
                    if (controller.libraryBooks.isNotEmpty)
                      _buildBookRow('Your Library', controller.libraryBooks),
                    _buildBookRow('All Books', controller.books),
                    if (controller.userBooks.isNotEmpty)
                      _buildBookRow('Your Published Books', controller.userBooks),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
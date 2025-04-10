import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

class LibraryController extends GetxController {
  final PocketBase pb;
  final String userId;
  final RxList<RecordModel> libraryItems = <RecordModel>[].obs;
  final RxBool isLoading = false.obs;
  String? errorMessage;

  LibraryController({
    required this.pb,
    required this.userId,
  });

  Future<void> fetchLibraryItems() async {
    try {
      isLoading.value = true;
      final result = await pb.collection('library_items').getList(
        page: 1,
        perPage: 50,
        filter: 'user = "$userId"',
        expand: 'book',
      );
      libraryItems.value = result.items;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load library items';
      print('Error fetching library items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addToLibrary(String bookId) async {
    try {
      await pb.collection('library_items').create(
        body: {
          'user': userId,
          'book': bookId,
        },
      );
      await fetchLibraryItems();
      return true;
    } catch (e) {
      print('Error adding to library: $e');
      return false;
    }
  }

  Future<bool> removeFromLibrary(String libraryItemId) async {
    try {
      await pb.collection('library_items').delete(libraryItemId);
      await fetchLibraryItems();
      return true;
    } catch (e) {
      print('Error removing from library: $e');
      return false;
    }
  }

  bool isInLibrary(String bookId) {
    return libraryItems.any((item) => item.data['book'] == bookId);
  }

  String? getLibraryItemId(String bookId) {
    final item = libraryItems.firstWhereOrNull((item) => item.data['book'] == bookId);
    return item?.id;
  }
} 
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/models/book_model.dart';

class BookDetailsController extends GetxController {
  final isLoading = true.obs;
  final Rx<Book?> book = Rx<Book?>(null);
  String? errorMessage;

  final String bookId;
  
  BookDetailsController({required this.bookId});

  @override
  void onInit() {
    super.onInit();
    fetchBookDetails();
  }

  Future<void> fetchBookDetails() async {
    try {
      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));
      final record = await pb.collection('books').getOne(
        bookId,
        expand: 'author',
      );

      book.value = Book.fromJson(record.data);
      isLoading.value = false;
    } catch (e) {
      errorMessage = 'Failed to load book details';
      isLoading.value = false;
    }
  }
}
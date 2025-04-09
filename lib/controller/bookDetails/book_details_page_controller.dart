import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/bookDetails/book_description_logic.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/utils/user_service.dart';

class BookDetailsController extends GetxController {
  final isLoading = true.obs;
  final Rx<Book?> book = Rx<Book?>(null);
  final hasDescription = false.obs;
  final Rx<String?> description = Rx<String?>(null);
  final Rx<String?> descriptionId = Rx<String?>(null);
  String? errorMessage;
  String? userId;
  final String bookId;
  final UserService _userService;
  
  UserService get userService => _userService; // Public accessor for extensions

  BookDetailsController({required this.bookId})
      : _userService = UserService(PocketBase(dotenv.get('POCKETBASE_URL')));

  @override
  void onInit() {
    super.onInit();
    _initializeUserId();
    fetchBookDetails();
    fetchDescription();
  }

  Future<void> _initializeUserId() async {
    userId = await _userService.getUserId();
  }

  Future<void> fetchBookDetails() async {
    isLoading.value = true;
    errorMessage = null;
    book.value = null;

    try {
      final record = await userService.pb
          .collection('books')
          .getOne(bookId, expand: 'author');
      book.value = Book.fromJson(record.data);
    } catch (e) {
      errorMessage = 'Failed to load book details: ${e.toString()}';
      Get.snackbar('Error', errorMessage!, snackPosition: SnackPosition.BOTTOM);
      print("Error fetching book details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String? get bookCoverThumbnailUrl {
    final currentBook = book.value;
    if (currentBook?.bookCover != null &&
        currentBook?.collectionId != null &&
        currentBook?.id != null) {
      return '${dotenv.get('POCKETBASE_URL')}/api/files/'
          '${currentBook!.collectionId}/${currentBook.id}/${currentBook.bookCover}?thumb=150x200';
    }
    return null;
  }
}
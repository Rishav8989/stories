import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:stories/screens/home%20screen/create_page.dart';
import '../../utils/user_service.dart';

class CreateBookController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  
  final Rx<String?> selectedGenre = Rx<String?>(null);
  final RxBool isLoading = false.obs;
  final Rx<XFile?> bookCover = Rx<XFile?>(null);
  
  // List of available genres
  final List<String> genres = [
    'Fantasy', 'Fiction', 'Science', 'Thriller', 'Horror', 'Romance',
    'Historical', 'Literary', 'Young Adult', 'Children\'s Fiction',
    'Adventure', 'Humor', 'Comedy', 'Fanfiction', 'Magical',
    'Biography', 'Non-Fiction', 'Other'
  ];

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );

    if (image != null) {
      bookCover.value = image;
    }
  }

  Future<void> createBook() async {
    // Validate form
    if (!formKey.currentState!.validate()) return;

    // Check if genre is selected
    if (selectedGenre.value == null) {
      Get.snackbar(
        'Missing Information',
        'Please select a Genre.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final userService = Get.find<UserService>();
      final userId = await userService.getUserId();

      if (userId == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      List<http.MultipartFile> files = [];
      if (bookCover.value != null) {
        files.add(await http.MultipartFile.fromPath(
          'book_cover',
          bookCover.value!.path,
        ));
      }

      // Create book record with hardcoded status and is_original values
      final book = await userService.pb.collection('books').create(
        body: {
          "title": titleController.text.trim(),
          "author": userId,
          "status": "draft",         // Hardcoded status
          "is_orignal": true,        // Hardcoded as true (original work)
          "Genre": selectedGenre.value!,
          "book_type": "Novels",
        },
        files: files,
      );

      Get.snackbar(
        'Success',
        'Book "${book.data['title']}" created successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reset form fields
      resetForm();
      
      // Navigate back to create page
      Get.off(() => const CreatePage());

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create book: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void resetForm() {
    formKey.currentState?.reset();
    titleController.clear();
    bookCover.value = null;
    selectedGenre.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }
}
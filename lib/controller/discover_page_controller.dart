import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/utils/user_service.dart';

class DiscoverController extends GetxController {
  final books = <Map<String, dynamic>>[].obs;
  final userBooks = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  String? errorMessage;
  
  final UserService _userService = UserService(PocketBase(dotenv.get('POCKETBASE_URL')));

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await Future.wait([
      fetchBooks(),
      fetchUserBooks(),
    ]);
  }

  Future<void> fetchBooks() async {
    try {
      final pb = PocketBase(dotenv.get('POCKETBASE_URL'));
      final resultList = await pb.collection('books').getList(
        page: 1,
        perPage: 50,
        filter: 'status = "published"',
        sort: 'updated', // Sort by updated date in descending order
      );

      books.value = resultList.items.map((item) => item.toJson()).toList();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage = 'Failed to load books. Please try again.';
      debugPrint('Error fetching books: $e');
    }
  }

  Future<void> fetchUserBooks() async {
    try {
      final userId = await _userService.getUserId();
      
      if (userId != null) {
        final resultList = await _userService.pb.collection('books').getList(
          page: 1,
          perPage: 50,
          filter: 'author = "$userId" && status = "published"',
          sort: 'updated', // Sort by updated date in descending order
        );

        userBooks.value = resultList.items.map((item) => item.toJson()).toList();
      }
    } catch (e) {
      debugPrint('Error fetching user books: $e');
    }
  }

  Future<void> refreshBooks() async {
    isLoading.value = true;
    errorMessage = null;
    await fetchInitialData();
  }
}
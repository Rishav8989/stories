import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/controller/library_controller.dart';

class DiscoverController extends GetxController {
  final books = <RecordModel>[].obs;
  final userBooks = <RecordModel>[].obs;
  final libraryBooks = <RecordModel>[].obs;
  final isLoading = true.obs;
  String? errorMessage;
  
  final UserService _userService = UserService(PocketBase(dotenv.get('POCKETBASE_URL')));
  late final LibraryController _libraryController;
  UnsubscribeFunc? _booksSubscription;
  UnsubscribeFunc? _userBooksSubscription;
  UnsubscribeFunc? _librarySubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeLibraryController();
    fetchInitialData();
    _subscribeToBooksChanges();
  }

  Future<void> _initializeLibraryController() async {
    try {
      final userId = await _userService.getUserId();
      if (userId != null) {
        _libraryController = Get.find<LibraryController>();
        await _libraryController.fetchLibraryItems();
      }
    } catch (e) {
      debugPrint('Error initializing library controller: $e');
    }
  }

  @override
  void onClose() {
    // Cancel the subscriptions
    _booksSubscription?.call();
    _userBooksSubscription?.call();
    _librarySubscription?.call();
    // Remove the pb.close() call since PocketBase doesn't have this method
    super.onClose();
  }

  Future<void> _subscribeToBooksChanges() async {
    try {
      // Subscribe to all published books
      _booksSubscription = await _userService.pb
          .collection('books')
          .subscribe('*', (e) {
        final record = e.record;
        if (record == null) return;

        switch (e.action) {
          case 'create':
            if (record.data['status'] == 'published') {
              books.insert(0, record);
            }
            break;
          case 'update':
            final index = books.indexWhere((book) => book.id == record.id);
            if (index != -1) {
              if (record.data['status'] == 'published') {
                books[index] = record;
              } else {
                books.removeAt(index);
              }
            }
            break;
          case 'delete':
            books.removeWhere((book) => book.id == record.id);
            break;
        }
      });

      // Subscribe to user's published books
      final userId = await _userService.getUserId();
      if (userId != null) {
        _userBooksSubscription = await _userService.pb
            .collection('books')
            .subscribe('*', (e) {
          final record = e.record;
          if (record == null) return;
          
          if (record.data['author'] != userId) return;

          switch (e.action) {
            case 'create':
              if (record.data['status'] == 'published') {
                userBooks.insert(0, record);
              }
              break;
            case 'update':
              final index = userBooks.indexWhere((book) => book.id == record.id);
              if (index != -1) {
                if (record.data['status'] == 'published') {
                  userBooks[index] = record;
                } else {
                  userBooks.removeAt(index);
                }
              }
              break;
            case 'delete':
              userBooks.removeWhere((book) => book.id == record.id);
              break;
          }
        });

        // Subscribe to library changes
        _librarySubscription = await _userService.pb
            .collection('library_items')
            .subscribe('*', (e) {
          final record = e.record;
          if (record == null) return;
          
          if (record.data['user'] != userId) return;

          switch (e.action) {
            case 'create':
              fetchLibraryBooks();
              break;
            case 'delete':
              fetchLibraryBooks();
              break;
          }
        });
      }
    } catch (e) {
      debugPrint('Error setting up realtime subscriptions: $e');
    }
  }

  Future<void> fetchInitialData() async {
    try {
      isLoading.value = true;
      errorMessage = null;
      
      // Always fetch published books
      await fetchBooks();
      
      // Only fetch user-specific data if logged in
      final userId = await _userService.getUserId();
      if (userId != null) {
        await Future.wait([
          fetchUserBooks(),
          fetchLibraryBooks(),
        ]);
      }
    } catch (e) {
      errorMessage = 'Failed to load books. Please try again.';
      debugPrint('Error fetching initial data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBooks() async {
    try {
      final resultList = await _userService.pb.collection('books').getList(
        page: 1,
        perPage: 50,
        filter: 'status = "published"',
        sort: '-updated',
      );

      books.value = resultList.items;
    } catch (e) {
      debugPrint('Error fetching books: $e');
      rethrow;
    }
  }

  Future<void> fetchUserBooks() async {
    try {
      final userId = await _userService.getUserId();
      if (userId == null) return;
      
      final resultList = await _userService.pb.collection('books').getList(
        page: 1,
        perPage: 50,
        filter: 'author = "$userId" && status = "published"',
        sort: '-updated',
      );

      userBooks.value = resultList.items;
    } catch (e) {
      debugPrint('Error fetching user books: $e');
      rethrow;
    }
  }

  Future<void> fetchLibraryBooks() async {
    try {
      final userId = await _userService.getUserId();
      if (userId == null) return;
      
      final libraryItems = await _userService.pb.collection('library_items').getList(
        page: 1,
        perPage: 50,
        filter: 'user = "$userId"',
        expand: 'book',
      );

      final bookRecords = <RecordModel>[];
      for (final item in libraryItems.items) {
        if (item.data['book'] != null) {
          final bookData = item.expand['book'];
          if (bookData is List) {
            final firstBook = (bookData as List?)?.firstOrNull;
            if (firstBook != null) {
              bookRecords.add(firstBook as RecordModel);
            }
          }
        }
      }

      libraryBooks.value = bookRecords;
    } catch (e) {
      debugPrint('Error fetching library books: $e');
      rethrow;
    }
  }

  Future<void> refreshBooks() async {
    isLoading.value = true;
    errorMessage = null;
    await fetchInitialData();
  }
}
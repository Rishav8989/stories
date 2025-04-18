import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/bookDetails/book_description_logic.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/utils/user_service.dart';
import 'package:stories/controller/chapter_controller.dart';
import 'package:stories/controller/bookDetails/chapter_management_logic.dart';
import 'package:stories/models/chapter_model.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class BookDetailsController extends GetxController with ChapterManagementLogic {
  final UserService userService;
  final String bookId;
  final PocketBase pb;
  final Rx<BookModel?> book = Rx<BookModel?>(null);
  final RxList<ChapterModel> chapters = <ChapterModel>[].obs;
  final RxBool isLoading = false.obs;
  final hasDescription = false.obs;
  final Rx<ChapterModel?> description = Rx<ChapterModel?>(null);
  final Rx<String?> descriptionId = Rx<String?>(null);
  String? userId;
  String? errorMessage;
  UnsubscribeFunc? _chaptersSubscription;

  // Add reactive variables for edit page
  final RxList<String> selectedGenres = <String>[].obs;
  final RxString selectedType = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  BookDetailsController({
    required this.userService,
    required this.bookId,
    required this.pb,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeUserId();
    if (bookId.isNotEmpty) {
      fetchBookDetails();
      fetchDescription();
      fetchChapters();
      _subscribeToChapters();
    }
  }

  @override
  void onClose() {
    _unsubscribeFromChapters();
    super.onClose();
  }

  void _unsubscribeFromChapters() {
    _chaptersSubscription?.call();
    _chaptersSubscription = null;
  }

  void _subscribeToChapters() async {
    _unsubscribeFromChapters();
    
    _chaptersSubscription = await pb.collection('chapters').subscribe('*', (e) {
      if (e.action == 'create' || e.action == 'update' || e.action == 'delete') {
        // Only update if the chapter belongs to this book
        if (e.record?.data['book'] == bookId && e.record?.data['type'] == 'content') {
          fetchChapters();
        }
      }
    }, filter: 'book = "$bookId" && type = "content"');
  }

  Future<void> _initializeUserId() async {
    userId = await userService.getUserId();
  }

  Future<void> fetchBookDetails() async {
    try {
      isLoading.value = true;
      final bookResult = await pb.collection('books').getOne(bookId);
      book.value = BookModel.fromJson(bookResult.toJson());
      await fetchDescription();
      await fetchChapters();
    } catch (e) {
      errorMessage = 'Failed to fetch book details: $e';
      Get.snackbar('Error', errorMessage!, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDescription() async {
    hasDescription.value = false;
    description.value = null;
    descriptionId.value = null;

    try {
      final result = await pb.collection('chapters').getFirstListItem(
        'book = "$bookId" && type = "description"',
      );
      description.value = ChapterModel.fromJson(result.toJson());
      hasDescription.value = true;
      descriptionId.value = result.id;
    } catch (e) {
      if (e is ClientException && e.statusCode == 404) {
        hasDescription.value = false;
      } else {
        print("Error fetching description: $e");
        Get.snackbar('Error', 'Failed to fetch description', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Future<void> fetchChapters() async {
    try {
      final result = await pb.collection('chapters').getList(
        filter: 'book = "$bookId" && type = "content"',
        sort: 'order_number',
        fields: 'id,title,order_number,status,type,book', // Only fetch necessary fields
      );
      chapters.value = result.items.map((item) => ChapterModel.fromJson(item.toJson())).toList();
    } catch (e) {
      print("Error fetching chapters: $e");
      Get.snackbar('Error', 'Failed to fetch chapters', backgroundColor: Colors.red);
    }
  }

  Future<int> getNextChapterOrderNumber() async {
    try {
      final result = await pb.collection('chapters').getList(
        filter: 'book = "$bookId" && type = "content"',
        sort: '-order_number',
        perPage: 1,
      );
      if (result.items.isEmpty) return 1;
      final lastOrderNumber = result.items.first.data['order_number'] as int;
      return lastOrderNumber + 1;
    } catch (e) {
      print("Error getting next order number: $e");
      return 1;
    }
  }

  String getBookCoverThumbnailUrl() {
    if (book.value?.bookCover == null) return '';
    return '${pb.baseUrl}/api/files/books/${book.value!.id}/${book.value!.bookCover}?thumb=100x100';
  }

  Future<void> updateBook(
    String bookId,
    String title,
    String description, {
    List<String>? genres,
    String? bookType,
    File? coverImage,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'description': description,
      };

      if (genres != null) {
        body['genre'] = genres;
      }

      if (bookType != null) {
        body['book_type'] = bookType;
      }

      if (coverImage != null) {
        final bytes = await coverImage.readAsBytes();
        final request = http.MultipartRequest(
          'PATCH',
          Uri.parse('${pb.baseUrl}/api/collections/books/records/$bookId'),
        );

        request.files.add(
          http.MultipartFile.fromBytes(
            'book_cover',
            bytes,
            filename: 'cover.jpg',
          ),
        );

        request.fields.addAll(body.map((key, value) {
          if (value is List) {
            return MapEntry(key, jsonEncode(value));
          }
          return MapEntry(key, value.toString());
        }));

        request.headers['Authorization'] = pb.authStore.token ?? '';

        final response = await request.send();
        if (response.statusCode != 200) {
          final errorBody = await response.stream.bytesToString();
          throw Exception('Failed to upload image: ${response.statusCode} - $errorBody');
        }
      } else {
        await pb.collection('books').update(bookId, body: body);
      }

      await fetchBookDetails();
      Get.snackbar('Success', 'Book updated successfully', backgroundColor: Colors.green);
    } catch (e) {
      print('Error updating book: $e');
      Get.snackbar(
        'Error',
        'Failed to update book: ${e.toString()}',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      );
      rethrow;
    }
  }

  Future<void> saveChapterOrder() async {
    try {
      for (var i = 0; i < chapters.length; i++) {
        await pb.collection('chapters').update(chapters[i].id, body: {
          'order_number': i + 1,
        });
      }
      await fetchChapters();
    } catch (e) {
      throw Exception('Failed to save chapter order: $e');
    }
  }

  void updateChapterOrder(List<ChapterModel> newOrder) {
    chapters.value = newOrder;
  }

  Future<void> updateChapter({
    required String chapterId,
    required String title,
    required String content,
  }) async {
    try {
      print('Updating chapter with bookId: $bookId'); // Debug log
      if (bookId.isEmpty) {
        throw Exception('BookId is empty. Please ensure the controller is properly initialized.');
      }
      
      final response = await pb.collection('chapters').update(
        chapterId,
        body: {
          'title': title,
          'content': content,
          'book': bookId,
          'type': 'content',
          'status': 'draft', // Ensure status is set
        },
      );
      print('Update response: $response'); // Debug log
      await fetchChapters();
    } catch (e) {
      print('Error updating chapter: $e');
      throw e;
    }
  }

  Future<void> exportBookAsPdf() async {
    try {
      isLoading.value = true;
      
      // Get all chapters sorted by order number
      final sortedChapters = chapters
          .where((chapter) => chapter.orderNumber != 0)
          .toList()
        ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

      // Create PDF document
      final pdf = pw.Document();

      // Load the Merriweather font
      final fontData = await rootBundle.load('assets/fonts/Merriweather-VariableFont_opsz,wdth,wght.ttf');
      final ttf = pw.Font.ttf(fontData);

      // Load cover image if exists
      Uint8List? coverImageBytes;
      if (book.value?.bookCover != null) {
        final response = await http.get(
          Uri.parse('${pb.baseUrl}/api/files/books/${book.value!.id}/${book.value!.bookCover}')
        );
        coverImageBytes = response.bodyBytes;
      }

      // Add cover page
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  if (coverImageBytes != null)
                    pw.Image(
                      pw.MemoryImage(coverImageBytes),
                      width: 200,
                      height: 300,
                    ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    book.value?.title ?? '',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Add each chapter
      for (final chapter in sortedChapters) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      chapter.title,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      chapter.content,
                      style: pw.TextStyle(
                        fontSize: 12,
                        font: ttf,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }

      // Save the PDF to a temporary file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/${book.value?.title ?? 'book'}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Handle sharing based on platform
      if (Platform.isLinux) {
        // For Linux, show a dialog with the file path
        Get.dialog(
          AlertDialog(
            title: const Text('PDF Exported'),
            content: Text('PDF has been saved to:\n${file.path}'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // For other platforms, use the share functionality
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '${book.value?.title ?? 'Book'} PDF Export',
        );
      }

      Get.snackbar('Success', 'Book exported successfully!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error exporting book: $e");
      Get.snackbar('Error', 'Failed to export book', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
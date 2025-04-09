import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/screens/bookDetail/book_detail_app_bar.dart';
import 'package:stories/screens/bookDetail/book_detail_content.dart';
import 'package:stories/utils/user_service.dart';

class BookDetailsPage extends GetView<BookDetailsController> {
  final String bookId;

  const BookDetailsPage({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookDetailsController>(
      init: BookDetailsController(
        bookId: bookId,
        userService: Get.find<UserService>(),
        pb: Get.find<PocketBase>(),
      ),
      builder: (controller) {
        return Scaffold(
          appBar: BookDetailAppBar(controller: controller),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Text(
                  controller.errorMessage!.toUpperCase(),
                  style: const TextStyle(letterSpacing: 0.5),
                ),
              );
            }

            final book = controller.book.value;
            if (book == null) {
              return const Center(
                child: Text(
                  'BOOK NOT FOUND',
                  style: TextStyle(letterSpacing: 0.5),
                ),
              );
            }

            return BookDetailContent(controller: controller, book: book);
          }),
        );
      },
    );
  }
}

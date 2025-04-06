import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stories/controller/book_details_page_controller.dart';
import 'package:stories/models/book_model.dart';
import 'package:stories/screens/bookDetail/book_detail_info_row.dart';

class BookDetailInfoCard extends StatelessWidget {
  final Book book;
  final BookDetailsController controller;

  const BookDetailInfoCard({
    Key? key,
    required this.book,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookDetailInfoRow(
                label: 'STATUS', value: book.status.toUpperCase()),
            const SizedBox(height: 16),
            BookDetailInfoRow(
                label: 'TYPE', value: book.bookType.toUpperCase()),
            const SizedBox(height: 16),
            BookDetailInfoRow(
                label: 'GENRES', value: book.genre.join(", ").toUpperCase()),
            const SizedBox(height: 16),
            BookDetailInfoRow(
              label: 'LAST UPDATED',
              value: DateFormat.yMMMd().format(book.updated).toUpperCase(),
            ),
            const SizedBox(height: 16),
            BookDetailInfoRow(
              label: 'SOURCE',
              value: (book.isOriginal
                      ? 'Original Work'
                      : 'Based on: ${book.parentBook ?? "Unknown"}')
                  .toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }
}

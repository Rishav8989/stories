import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'package:stories/models/chapter_model.dart';

class ReorderChaptersPage extends StatelessWidget {
  final BookDetailsController controller;

  const ReorderChaptersPage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Chapters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              try {
                await controller.saveChapterOrder();
                Get.back();
                Get.snackbar('Success', 'Chapter order updated successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to update chapter order');
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final chapters = controller.chapters.toList();
        return ReorderableListView.builder(
          itemCount: chapters.length,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final chapter = chapters.removeAt(oldIndex);
            chapters.insert(newIndex, chapter);
            controller.updateChapterOrder(chapters);
          },
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return ListTile(
              key: Key(chapter.id),
              title: Text(chapter.title),
              subtitle: Text('Chapter ${chapter.orderNumber}'),
              trailing: const Icon(Icons.drag_handle),
            );
          },
        );
      }),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/models/chapter_model.dart';

mixin ChapterManagementLogic {
  PocketBase get pb;
  String get bookId;
  RxList<ChapterModel> get chapters;
  
  Future<void> fetchChapters();

  Future<void> updateChapter({
    required String chapterId,
    required String title,
    required String content,
  }) async {
    try {
      await pb.collection('chapters').update(chapterId, body: {
        "title": title,
        "content": content,
        "book": bookId,
      });
      await fetchChapters();
      Get.back();
      Get.snackbar('Success', 'Chapter updated!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error updating chapter: $e");
      Get.snackbar('Error', 'Failed to update chapter: $e', backgroundColor: Colors.red);
    }
  }

  Future<void> deleteChapter(String chapterId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Chapter'),
        content: const Text('Are you sure you want to delete this chapter? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await pb.collection('chapters').delete(chapterId);
      await fetchChapters();
      Get.snackbar('Success', 'Chapter deleted!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error deleting chapter: $e");
      Get.snackbar('Error', 'Failed to delete chapter', backgroundColor: Colors.red);
    }
  }

  Future<void> reorderChapters(List<ChapterModel> reorderedChapters) async {
    try {
      for (var i = 0; i < reorderedChapters.length; i++) {
        final chapter = reorderedChapters[i];
        await pb.collection('chapters').update(chapter.id, body: {
          "order_number": i + 1,
        });
      }
      await fetchChapters();
      Get.snackbar('Success', 'Chapters reordered!', backgroundColor: Colors.green);
    } catch (e) {
      print("Error reordering chapters: $e");
      Get.snackbar('Error', 'Failed to reorder chapters', backgroundColor: Colors.red);
    }
  }
} 
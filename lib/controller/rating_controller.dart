import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/models/rating_model.dart';
import 'package:stories/utils/user_service.dart';

class RatingController extends GetxController {
  final UserService _userService;
  final String bookId;
  final ratings = <RatingModel>[].obs;
  final userRating = Rx<RatingModel?>(null);
  final averageRating = 0.0.obs;
  final totalRatings = 0.obs;
  final isLoading = false.obs;

  RatingController({
    required UserService userService,
    required this.bookId,
  }) : _userService = userService;

  @override
  void onInit() {
    super.onInit();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    try {
      isLoading.value = true;
      final userId = await _userService.getUserId();
      
      // Fetch all ratings for the book
      final result = await _userService.pb.collection('ratings').getList(
        filter: 'book = "$bookId"',
        expand: 'user',
      );

      // Convert to RatingModel list
      ratings.value = result.items.map((item) => RatingModel.fromJson(item.toJson())).toList();

      // Calculate average rating
      if (ratings.isNotEmpty) {
        final sum = ratings.fold<int>(0, (sum, item) => sum + item.rating);
        averageRating.value = sum / ratings.length;
        totalRatings.value = ratings.length;
      }

      // Find user's rating if they're logged in
      if (userId != null) {
        userRating.value = ratings.firstWhereOrNull((rating) => rating.user == userId);
      }
    } catch (e) {
      print('Error fetching ratings: $e');
      Get.snackbar(
        'Error',
        'Failed to load ratings',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rateBook(int rating, {String? comment}) async {
    try {
      isLoading.value = true;
      final userId = await _userService.getUserId();
      
      if (userId == null) {
        Get.snackbar(
          'Error',
          'Please log in to rate books',
          backgroundColor: Colors.red,
        );
        return;
      }

      final data = {
        'user': userId,
        'book': bookId,
        'rating': rating.toString(),
        if (comment != null && comment.isNotEmpty) 'review_comment': comment,
      };

      if (userRating.value != null) {
        // Update existing rating
        await _userService.pb.collection('ratings').update(
          userRating.value!.id,
          body: data,
        );
      } else {
        // Create new rating
        await _userService.pb.collection('ratings').create(body: data);
      }

      await fetchRatings();
      Get.snackbar(
        'Success',
        'Rating submitted successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print('Error rating book: $e');
      Get.snackbar(
        'Error',
        'Failed to submit rating',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRating() async {
    try {
      if (userRating.value == null) return;

      isLoading.value = true;
      await _userService.pb.collection('ratings').delete(userRating.value!.id);
      await fetchRatings();
      
      Get.snackbar(
        'Success',
        'Rating removed successfully',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print('Error deleting rating: $e');
      Get.snackbar(
        'Error',
        'Failed to remove rating',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 
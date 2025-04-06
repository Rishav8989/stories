import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:stories/controller/profile_controller.dart';

void main() {
  late ProfileController profileController;

  setUp(() {
    profileController = ProfileController();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('ProfileController Tests', () {
    test('initial values should be correct', () {
      expect(profileController.isLoading.value, true);
      expect(profileController.error.value, '');
      expect(profileController.userData.value, isEmpty);
    });

    test('fetchUserData should handle errors', () async {
      await profileController.fetchUserData();
      expect(profileController.error.value.isNotEmpty, true);
    });

    test('getProfileImageUrl should return null for empty avatar', () {
      final url = profileController.getProfileImageUrl(null);
      expect(url, isNull);
    });
  });
}
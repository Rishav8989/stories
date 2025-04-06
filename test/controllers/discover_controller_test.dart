import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:stories/controller/discover_page_controller.dart';

void main() {
  late DiscoverController discoverController;

  setUp(() {
    discoverController = DiscoverController();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('DiscoverController Tests', () {
    test('initial values should be correct', () {
      expect(discoverController.isLoading.value, true);
      expect(discoverController.errorMessage, isNull);
      expect(discoverController.books, isEmpty);
      expect(discoverController.userBooks, isEmpty);
    });

    test('refreshBooks should reset error state', () async {
      discoverController.errorMessage = 'Previous error';
      await discoverController.refreshBooks();
      expect(discoverController.errorMessage, isNull);
    });
  });
}
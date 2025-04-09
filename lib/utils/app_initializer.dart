import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/auth_controller.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/utils/user_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:stories/controller/font_controller.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';

class AppInitializer {
  static Future<void> init() async {
    // First run dummy GetMaterialApp to initialize GetX
    Get.put(GetMaterialController());
    
    // Check and request permissions
    await _requestPermissions();

    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    // Initialize PocketBase instance
    final PocketBase pb = PocketBase(dotenv.get('POCKETBASE_URL'));
    Get.put(pb, permanent: true);

    // Initialize controllers
    final themeController = Get.put(ThemeController());
    final fontController = Get.put(FontController());
    
    // Wait for both theme and font to load
    await Future.wait([
      themeController.loadInitialTheme(),
      fontController.loadFontFromPreferences(),
    ]);

    // Force initial theme update
    Get.changeTheme(themeController.themeData);
    Get.changeThemeMode(themeController.themeMode);

    // Initialize remaining services and controllers
    Get.put(UserService(pb));
    Get.put(AuthController(pb));
    Get.lazyPut<BookDetailsController>(() => BookDetailsController(
      userService: Get.find<UserService>(),
      pb: Get.find<PocketBase>(),
      bookId: '', // This will be set when needed
    ), fenix: true);
  }

  static Future<void> _requestPermissions() async {
    try {
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await Get.dialog(
          Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Please check your internet connection and try again.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
        return;
      }

      // Request storage permissions
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isDenied || storageStatus.isPermanentlyDenied) {
        await Get.dialog(
          Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Storage Permission Required',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This app needs storage access to save books and profile pictures. '
                    'Please grant storage permission in settings.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          await openAppSettings();
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print('Permission request error: $e');
    }
  }
}
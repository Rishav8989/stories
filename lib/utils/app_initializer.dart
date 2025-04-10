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
import 'package:stories/controller/library_controller.dart';
import 'package:stories/services/account_service.dart';
import 'dart:io' show Platform;

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
    final userService = Get.put(UserService(pb));
    Get.put(AccountService(pb));
    Get.put(AuthController(pb));
    Get.lazyPut<BookDetailsController>(() => BookDetailsController(
      userService: Get.find<UserService>(),
      pb: Get.find<PocketBase>(),
      bookId: '', // This will be set when needed
    ), fenix: true);
    
    // Initialize library controller
    final userId = await userService.getUserId();
    Get.lazyPut<LibraryController>(() => LibraryController(
      pb: pb,
      userId: userId ?? '',
    ), fenix: true);
  }

  static Future<void> _requestPermissions() async {
    try {
      // Only request permissions on mobile platforms
      if (Platform.isAndroid || Platform.isIOS) {
        // Request storage permission for caching images
        await Permission.storage.request();
        // Request internet connectivity permission
        await Permission.accessMediaLocation.request();
      }
    } catch (e) {
      print('Permission request error: $e');
      // Continue without permissions on desktop platforms
    }
  }
}
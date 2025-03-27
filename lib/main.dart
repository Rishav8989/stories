import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/auth_controller.dart';
import 'package:stories/routes/app_routes.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/utils/theme/app_theme.dart';
import 'package:stories/utils/user_service.dart';
import 'package:pocketbase/pocketbase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ThemeController
  final ThemeController themeController = Get.put(ThemeController());
  await themeController.loadInitialTheme();

  // Initialize UserService
  final PocketBase pb = PocketBase('http://rishavpocket.duckdns.org');
  Get.put(UserService(pb)); // Register UserService

  // Initialize AuthController
  Get.put(AuthController()); // Register AuthController

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stories App',
      locale: Get.deviceLocale, // Set the locale to the device's locale
      fallbackLocale: const Locale('en', 'US'), // Fallback locale
      theme: lightTheme, // Light theme
      darkTheme: darkTheme, // Dark theme
      themeMode: Get.find<ThemeController>().themeMode, // Dynamic theme mode
      initialRoute: AppRoutes.home, // Set the initial route
      getPages: AppRoutes.pages, // Define app routes
    );
  }
}
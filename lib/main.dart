import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/controller/auth_controller.dart';
import 'package:stories/routes/app_routes.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/utils/theme/app_theme.dart';
import 'package:stories/utils/user_service.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize PocketBase instance
    await dotenv.load(fileName: ".env");
  final PocketBase pb = PocketBase(dotenv.get('POCKETBASE_URL'));

  // Initialize ThemeController
  final ThemeController themeController = Get.put(ThemeController());
  await themeController.loadInitialTheme();

  // Initialize UserService with pb instance
  Get.put(UserService(pb));

  // Initialize AuthController with pb instance
  Get.put(AuthController(pb));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stories App',
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Get.find<ThemeController>().themeMode,
      initialRoute: AppRoutes.home,
      getPages: AppRoutes.pages,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/routes/app_routes.dart';
import 'package:stories/utils/app_initializer.dart';
import 'package:stories/utils/theme/app_theme.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/controller/font_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();
    final themeController = Get.find<ThemeController>();
    
    return Obx(() {
      final currentFont = fontController.selectedFont.value;
      final currentTheme = themeController.themeData;
      
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stories App',
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        theme: currentTheme.copyWith(
          textTheme: currentTheme.textTheme.apply(
            fontFamily: currentFont,
          ),
          appBarTheme: currentTheme.appBarTheme.copyWith(
            titleTextStyle: currentTheme.appBarTheme.titleTextStyle?.copyWith(
              fontFamily: currentFont,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: TextStyle(
                fontFamily: currentFont,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        themeMode: themeController.themeMode,
        initialRoute: AppRoutes.home,
        getPages: AppRoutes.pages,
      );
    });
  }
}
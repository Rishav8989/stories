import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/routes/app_routes.dart';
import 'package:stories/utils/app_initializer.dart';
import 'package:stories/utils/theme/app_theme.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/controller/font_controller.dart';
import 'package:google_fonts/google_fonts.dart';

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
          textTheme: GoogleFonts.getTextTheme(
            currentFont,
            currentTheme.textTheme,
          ),
          appBarTheme: currentTheme.appBarTheme.copyWith(
            titleTextStyle: GoogleFonts.getFont(
              currentFont,
              textStyle: currentTheme.appBarTheme.titleTextStyle,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.getFont(
                currentFont,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
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
// utils/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart'; // Import your theme definitions

enum AppTheme {
  lightReading,    // Bright, high-contrast for daytime reading
  sepia,          // Warm, paper-like for extended reading
  darkReading,    // Standard dark mode for night reading
  amoledDark,     // True black for OLED screens
  highContrast,   // High contrast for accessibility
  paperWhite,     // Soft white with minimal blue light
  nightLight,     // Warm dark mode for night reading
}

class ThemeController extends GetxController {
  final Rx<AppTheme> currentTheme = AppTheme.lightReading.obs;
  late SharedPreferences _prefs;
  final String _themeKey = 'app_theme';
  bool _isThemeLoaded = false; // Track if theme is loaded

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPreferences();
  }

  Future<void> loadInitialTheme() async {
    await _loadThemeFromPreferences();
    Get.changeTheme(themeData);
    Get.changeThemeMode(themeMode);
  }

  AppTheme get selectedTheme => currentTheme.value;

  ThemeMode get themeMode {
    if (!_isThemeLoaded) {
      return ThemeMode.system; // Or any default mode until theme is loaded
    }
    switch (currentTheme.value) {
      case AppTheme.lightReading:
      case AppTheme.sepia:
      case AppTheme.paperWhite:
      case AppTheme.highContrast:
        return ThemeMode.light;
      case AppTheme.darkReading:
      case AppTheme.amoledDark:
      case AppTheme.nightLight:
        return ThemeMode.dark;
    }
  }

  ThemeData get themeData {
    if (!_isThemeLoaded) {
      return lightReadingTheme; // Or any default theme until theme is loaded
    }
    switch (currentTheme.value) {
      case AppTheme.lightReading:
        return lightReadingTheme;
      case AppTheme.sepia:
        return sepiaTheme;
      case AppTheme.darkReading:
        return darkReadingTheme;
      case AppTheme.amoledDark:
        return amoledDarkTheme;
      case AppTheme.highContrast:
        return highContrastTheme;
      case AppTheme.paperWhite:
        return paperWhiteTheme;
      case AppTheme.nightLight:
        return nightLightTheme;
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    currentTheme.value = theme;
    await _saveThemeToPreferences(theme);
    Get.changeTheme(themeData);
    Get.changeThemeMode(themeMode);
    Get.forceAppUpdate();
  }

  void switchToLightReadingTheme() {
    currentTheme.value = AppTheme.lightReading;
    Get.forceAppUpdate();
  }

  void switchToSepiaTheme() {
    currentTheme.value = AppTheme.sepia;
    Get.forceAppUpdate();
  }

  void switchToDarkReadingTheme() {
    currentTheme.value = AppTheme.darkReading;
    Get.forceAppUpdate();
  }

  void switchToAmoledDarkTheme() {
    currentTheme.value = AppTheme.amoledDark;
    Get.forceAppUpdate();
  }

  void switchToHighContrastTheme() {
    currentTheme.value = AppTheme.highContrast;
    Get.forceAppUpdate();
  }

  void switchToPaperWhiteTheme() {
    currentTheme.value = AppTheme.paperWhite;
    Get.forceAppUpdate();
  }

  void switchToNightLightTheme() {
    currentTheme.value = AppTheme.nightLight;
    Get.forceAppUpdate();
  }

  Future<void> _loadThemeFromPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final themeName = _prefs.getString(_themeKey);
    if (themeName != null) {
      try {
        currentTheme.value = AppTheme.values.byName(themeName);
      } catch (e) {
        // If theme name is invalid, use default theme
        currentTheme.value = AppTheme.lightReading;
      }
    }
    _isThemeLoaded = true;
  }

  Future<void> _saveThemeToPreferences(AppTheme theme) async {
    await _prefs.setString(_themeKey, theme.name);
  }
}
// utils/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart'; // Import your theme definitions

enum AppTheme {
  light,
  dark,
}

class ThemeController extends GetxController {
  final _currentTheme = AppTheme.light.obs;
  late SharedPreferences _prefs;
  final String _themeKey = 'app_theme';
  bool _isThemeLoaded = false; // Track if theme is loaded


  // New function to load theme initially in main.dart  <-----  THIS IS THE IMPORTANT PART!
  Future<void> loadInitialTheme() async {
    await _loadThemeFromPreferences();
    _isThemeLoaded = true; // Mark theme as loaded
  }

  AppTheme get currentTheme => _currentTheme.value;

  ThemeMode get themeMode {
    if (!_isThemeLoaded) {
      return ThemeMode.system; // Or any default mode until theme is loaded
    }
    switch (_currentTheme.value) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  ThemeData get themeData {
    if (!_isThemeLoaded) {
      return lightTheme; // Or any default theme until theme is loaded
    }
    switch (_currentTheme.value) {
      case AppTheme.light:
        return lightTheme;
      case AppTheme.dark:
        return darkTheme;
      default:
        return lightTheme;
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme.value = theme;
    Get.changeTheme(themeData);
    Get.changeThemeMode(themeMode);
    await _saveThemeToPreferences(theme);
  }

  void switchToLightTheme() => setTheme(AppTheme.light);
  void switchToDarkTheme() => setTheme(AppTheme.dark);

  Future<void> _loadThemeFromPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? themeName = _prefs.getString(_themeKey);
    if (themeName != null) {
      try {
        _currentTheme.value = AppTheme.values.byName(themeName);
        Get.changeTheme(themeData);
        Get.changeThemeMode(themeMode);
      } catch (e) {
        print('Error loading theme: $e');
      }
    }
  }

  Future<void> _saveThemeToPreferences(AppTheme theme) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(_themeKey, theme.name);
  }
}
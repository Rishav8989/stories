import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontController extends GetxController {
  final RxString _selectedFont = 'Merriweather'.obs;
  final List<String> _availableFonts = [
    'Roboto',
    'Merriweather',
    'Lora',
    'Playfair Display',
    'Source Serif Pro',
    'Noto Serif',
    'Crimson Text',
    'Alegreya',
  ];
  late SharedPreferences _prefs;
  final String _fontKey = 'app_font';

  String get selectedFont => _selectedFont.value;
  List<String> get availableFonts => _availableFonts;

  @override
  void onInit() {
    super.onInit();
    _loadFontFromPreferences();
  }

  Future<void> _loadFontFromPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedFont = _prefs.getString(_fontKey);
    if (savedFont != null && _availableFonts.contains(savedFont)) {
      _selectedFont.value = savedFont;
    }
  }

  Future<void> changeFont(String font) async {
    if (_availableFonts.contains(font)) {
      _selectedFont.value = font;
      await _saveFontToPreferences(font);
      Get.forceAppUpdate(); // Force UI update
    }
  }

  Future<void> _saveFontToPreferences(String font) async {
    await _prefs.setString(_fontKey, font);
  }

  TextStyle getTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontFamily: _selectedFont.value,
    );
  }
} 
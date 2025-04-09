import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontController extends GetxController {
  final RxString selectedFont = 'Roboto'.obs;
  final List<String> _availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Merriweather',
    'Noto Sans'
  ];
  late SharedPreferences _prefs;
  final String _fontKey = 'app_font';

  List<String> get availableFonts => _availableFonts;

  @override
  void onInit() {
    super.onInit();
    _loadFontFromPreferences();
  }

  Future<void> _loadFontFromPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final fontName = _prefs.getString(_fontKey);
    if (fontName != null) {
      selectedFont.value = fontName;
    }
  }

  Future<void> _saveFontToPreferences(String font) async {
    await _prefs.setString(_fontKey, font);
  }

  void switchToRoboto() {
    selectedFont.value = 'Roboto';
    _saveFontToPreferences('Roboto');
  }

  void switchToOpenSans() {
    selectedFont.value = 'Open Sans';
    _saveFontToPreferences('Open Sans');
  }

  void switchToLato() {
    selectedFont.value = 'Lato';
    _saveFontToPreferences('Lato');
  }

  void switchToMerriweather() {
    selectedFont.value = 'Merriweather';
    _saveFontToPreferences('Merriweather');
  }

  void switchToNotoSans() {
    selectedFont.value = 'Noto Sans';
    _saveFontToPreferences('Noto Sans');
  }

  TextStyle getTextStyle(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontFamily: selectedFont.value,
    );
  }
} 
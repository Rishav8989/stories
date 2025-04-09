import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stories/models/chapter_model.dart';
import 'package:stories/controller/bookDetails/book_details_page_controller.dart';
import 'dart:convert';

class ReaderController extends GetxController {
  final RxDouble fontSize = 16.0.obs;
  final RxDouble lineSpacing = 1.5.obs;
  final RxDouble paragraphSpacing = 16.0.obs;
  final RxString selectedFont = 'Merriweather'.obs;
  final RxBool isDarkMode = false.obs;
  final RxMap<String, double> readingProgress = <String, double>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> highlights = <String, List<Map<String, dynamic>>>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> notes = <String, List<Map<String, dynamic>>>{}.obs;
  final RxMap<String, int> readingTime = <String, int>{}.obs;
  final RxMap<String, int> readingSpeed = <String, int>{}.obs;
  final RxMap<String, List<String>> bookmarks = <String, List<String>>{}.obs;
  
  late SharedPreferences _prefs;
  final String _progressKey = 'reading_progress';
  final String _highlightsKey = 'highlights';
  final String _notesKey = 'notes';
  final String _readingTimeKey = 'reading_time';
  final String _readingSpeedKey = 'reading_speed';
  final String _bookmarksKey = 'bookmarks';
  final String _settingsKey = 'reader_settings';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _loadProgress();
    _loadHighlights();
    _loadNotes();
    _loadReadingStats();
    _loadBookmarks();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    fontSize.value = _prefs.getDouble('${_settingsKey}_fontSize') ?? 16.0;
    lineSpacing.value = _prefs.getDouble('${_settingsKey}_lineSpacing') ?? 1.5;
    paragraphSpacing.value = _prefs.getDouble('${_settingsKey}_paragraphSpacing') ?? 16.0;
    selectedFont.value = _prefs.getString('${_settingsKey}_font') ?? 'Merriweather';
    isDarkMode.value = _prefs.getBool('${_settingsKey}_darkMode') ?? false;
  }

  Future<void> _loadProgress() async {
    _prefs = await SharedPreferences.getInstance();
    final progress = _prefs.getString(_progressKey);
    if (progress != null) {
      readingProgress.value = Map<String, double>.from(json.decode(progress));
    }
  }

  Future<void> _loadHighlights() async {
    _prefs = await SharedPreferences.getInstance();
    final highlightsStr = _prefs.getString(_highlightsKey);
    if (highlightsStr != null) {
      highlights.value = Map<String, List<Map<String, dynamic>>>.from(json.decode(highlightsStr));
    }
  }

  Future<void> _loadNotes() async {
    _prefs = await SharedPreferences.getInstance();
    final notesStr = _prefs.getString(_notesKey);
    if (notesStr != null) {
      notes.value = Map<String, List<Map<String, dynamic>>>.from(json.decode(notesStr));
    }
  }

  Future<void> _loadReadingStats() async {
    _prefs = await SharedPreferences.getInstance();
    final timeStr = _prefs.getString(_readingTimeKey);
    final speedStr = _prefs.getString(_readingSpeedKey);
    if (timeStr != null) {
      readingTime.value = Map<String, int>.from(json.decode(timeStr));
    }
    if (speedStr != null) {
      readingSpeed.value = Map<String, int>.from(json.decode(speedStr));
    }
  }

  Future<void> _loadBookmarks() async {
    _prefs = await SharedPreferences.getInstance();
    final bookmarksStr = _prefs.getString(_bookmarksKey);
    if (bookmarksStr != null) {
      bookmarks.value = Map<String, List<String>>.from(json.decode(bookmarksStr));
    }
  }

  Future<void> saveSettings() async {
    await _prefs.setDouble('${_settingsKey}_fontSize', fontSize.value);
    await _prefs.setDouble('${_settingsKey}_lineSpacing', lineSpacing.value);
    await _prefs.setDouble('${_settingsKey}_paragraphSpacing', paragraphSpacing.value);
    await _prefs.setString('${_settingsKey}_font', selectedFont.value);
    await _prefs.setBool('${_settingsKey}_darkMode', isDarkMode.value);
  }

  Future<void> saveProgress(String chapterId, double progress) async {
    readingProgress[chapterId] = progress;
    await _prefs.setString(_progressKey, json.encode(readingProgress));
  }

  Future<void> addHighlight(String chapterId, String text, int start, int end) async {
    if (!highlights.containsKey(chapterId)) {
      highlights[chapterId] = [];
    }
    highlights[chapterId]!.add({
      'text': text,
      'start': start,
      'end': end,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_highlightsKey, json.encode(highlights));
  }

  Future<void> addNote(String chapterId, String text, int position) async {
    if (!notes.containsKey(chapterId)) {
      notes[chapterId] = [];
    }
    notes[chapterId]!.add({
      'text': text,
      'position': position,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_notesKey, json.encode(notes));
  }

  Future<void> updateReadingStats(String chapterId, int timeSpent, int wordsRead) async {
    readingTime[chapterId] = (readingTime[chapterId] ?? 0) + timeSpent;
    readingSpeed[chapterId] = (wordsRead / (timeSpent / 60)).round(); // Words per minute
    await _prefs.setString(_readingTimeKey, json.encode(readingTime));
    await _prefs.setString(_readingSpeedKey, json.encode(readingSpeed));
  }

  Future<void> addBookmark(String chapterId, String text) async {
    if (!bookmarks.containsKey(chapterId)) {
      bookmarks[chapterId] = [];
    }
    bookmarks[chapterId]!.add(text);
    await _prefs.setString(_bookmarksKey, json.encode(bookmarks));
  }

  Future<void> removeBookmark(String chapterId, String text) async {
    if (bookmarks.containsKey(chapterId)) {
      bookmarks[chapterId]!.remove(text);
      await _prefs.setString(_bookmarksKey, json.encode(bookmarks));
    }
  }

  double getChapterProgress(String chapterId) {
    return readingProgress[chapterId] ?? 0.0;
  }

  List<Map<String, dynamic>> getChapterHighlights(String chapterId) {
    return highlights[chapterId] ?? [];
  }

  List<Map<String, dynamic>> getChapterNotes(String chapterId) {
    return notes[chapterId] ?? [];
  }

  int getChapterReadingTime(String chapterId) {
    return readingTime[chapterId] ?? 0;
  }

  int getChapterReadingSpeed(String chapterId) {
    return readingSpeed[chapterId] ?? 0;
  }

  List<String> getChapterBookmarks(String chapterId) {
    return bookmarks[chapterId] ?? [];
  }
} 
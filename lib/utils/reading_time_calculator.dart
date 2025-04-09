class ReadingTimeCalculator {
  static const int wordsPerMinute = 200; // Average reading speed

  static String calculateReadingTime(String text) {
    if (text.isEmpty) return '0 min read';
    
    // Count words (split by whitespace and filter empty strings)
    final wordCount = text.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    
    // Calculate minutes (round up to nearest minute)
    final minutes = (wordCount / wordsPerMinute).ceil();
    
    if (minutes == 0) return 'Less than 1 min read';
    if (minutes == 1) return '1 min read';
    return '$minutes mins read';
  }
} 